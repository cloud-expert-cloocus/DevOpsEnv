# DevOpsEnv
DevOps 환경 설정 스크립트, infrastructure as Code를 위한 표준 템플릿 [일관된 빌드 품질과 효율성을 유지하기 위한 모범 사례]

<img src="/image/iac_cicd_flow.png" width="850px" height="300px" title="px(픽셀) 크기 설정" alt="IaC + CICD on Azure"></img><br/>
# 구조 설명
실제 GitHub의 Action을 활성화 하려면 ".yml"파일을 ".github"디렉토리 아래로 이동 시키고 완성하거나 참고하여 Action 메뉴에서 Workflow를 작성해야 합니다.
[GitHub 공식 홈의 Actions 기능 설명](https://github.com/features/actions)
<br>
Terraform 디렉토리는 terraform.yml와 동일한 위치에 존재 해야 합니다.
> Template 
>	> CI-CD : [GitHub Actions On Azure](https://docs.microsoft.com/ko-kr/azure/app-service/deploy-github-actions?tabs=applevel)
>	> > azure-cicd.yml : nodejs를 Azure Web App 리소스에 배포하는 샘플 GitHub Workflow 
>	>
>	> IaC
> > > Terrform : 테라폼으로 Azure 리소스를 배포하기 위한 정의 파일, [Terraform 바로가기](https://www.terraform.io/intro/index.html)
> > > > main.tf 
> > > > 
> > > > provider.tf
> > > > 
> > > > variable.tf
> > > > 
> > > terraform.yml : 테라폼으로 Azure 리소스를 배포하기 위한 GiHub Workfow

# azure-cicd.yml 설명
Azure에 nodejs로 구성된 Web App을 자동으로 빌드하고 배포(CI/CD)하는 샘플 Workflow
<pre><code>
name: {{Web App CI CD Sample Name}} # 해당 Workflow의 이름

on: [push]  # 어떤 동작에 해당 Action 트리거 할 것인지 push, pull request, ...

env:  # 해당 Workflow에서 사용될 환경 변수 정의
  AZURE_WEBAPP_NAME: {{Your-WebApp-Name}} # prdopswithgithub # set this to your application's name
  AZURE_WEBAPP_PACKAGE_PATH: './'      # set this to the path to your web app project, defaults to the repository root
  NODE_VERSION: '10.x'                # set this to the node version to use

jobs: # 실제 동작할 작업 정의
  build-and-deploy: # 작업의 Key name
    name: Build and Deploy  # 표시될 작업의 이름
    runs-on: ubuntu-latest  # 해당 작업이 수행될 운영 환경 정의
    steps:                  # steps 아래부터 순서대로 수행 될 작업 정의
    # checkout the repo
    - name: 'Checkout GitHub Action' 
      uses: actions/checkout@main
   
    # 발급한 Azure Service Principal을 이용해 Azure에 로그인
    - uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
    
    # 지정한 버전 node.js 설치
    - name: Setup Node ${{ env.NODE_VERSION }}
      uses: actions/setup-node@v1
      with:
        node-version: ${{ env.NODE_VERSION }}
   
    # run은 쉘 스크립트 실행과 동일
    # - name: 'npm install, build, and test'
    - run: npm ci
    - run: npm run build --if-present
    - run: npm test
             
    # Azure credentials 이용해 지정한 Wep App에 배포
    - uses: azure/webapps-deploy@v2
      with:
        app-name: ${{ env.AZURE_WEBAPP_NAME }}
        package: ${{ env.AZURE_WEBAPP_PACKAGE_PATH }}

    # 슬랙채널로 Notification 보내기
    - name: action-slack
      uses: 8398a7/action-slack@v3
      with:
        job_name: Build and Deploy
        status: ${{ job.status }}
        author_name: Github Action Noti # default: 8398a7@action-slack
        fields: repo,message,commit,author,action,eventName,ref,workflow,job,took
      env:
        SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }} # required
      if: always() # Pick up events even if the job fails or is canceled.

    # Azure logout 
    - name: logout
      run: |
        az logout
</code></pre>

# terraform.yml 설명
main.tf에 정의된 Azure 리소스를 일관되게 배포 하는 샘플 Workflow
<pre><code>
# Terraform 인프라 배포에 대한 샘플 코드입니다.

name: 'Terraform'

# Push하면 해당 branch에서 pipeline 구동
on:
  push:
    branches:
    # - main

# 환경변수 지정
env:
  tf_actions_working_dir: ./Terraform

# ubuntu-latest로 GitHub Actions를 구동/ working-directory 지정
jobs:
  terraform:
    name: 'Terraform'
    runs-on: ubuntu-latest
    environment: production

    defaults:
      run:
        shell: bash
        working-directory: ${{ env.tf_actions_working_dir }}

    steps:
    # GitHub 소스 체크
    - name: Checkout
      uses: actions/checkout@v2

    # 최신버전 설치/ TF Cloud API 토큰 인증
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v1
      with:
        cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}

    # Terraform init - 백엔드 초기화/ 플러그인, 모듈 설치
    - name: Terraform Init
      run: terraform init
      
    # Terraform Validate - 문법 검사
    - name: Terraform Validate
      id: validate
      run: terraform validate -no-color

    # Terraform Plan - 배포하기 전 검토/ 변경 사항에 대해 확인
    - name: Terraform Plan
      run: terraform plan

    # Terraform Apply - Plan에 제안된 작업을 실행
    - name: Terraform Apply
      if: github.event_name == 'push'
      run: terraform apply -auto-approve
</code></pre>
