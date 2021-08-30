# DevOpsEnv
DevOps 환경 설정 스크립트, infrastructure as Code를 위한 표준 템플릿 [일관된 빌드 품질과 효율성을 유지하기 위한 모범 사례]

# 구조 설명
실제 GitHub의 Action을 활성화 하려면 "Template"디렉토리를 ".github"으로 변경하거나 Action 메뉴에서 Workflow를 작성해야 합니다.
> Template 
>	> CI-CD
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

