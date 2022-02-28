#  Terraform Info - PRD

# Resource Group
- thira-stg-mes-rg  = mes와 연관된 리소스 그룹
- thira-stg-mes-nrg = aks nodepool(vmss)와 연관된 리소스 그룹
- thira-rsg = Key Vault(인증키 저장)와 Storage Account(Terraform .tfstate file 저장)


# Terraform
- CLI, API, UI/VCS
- main_stg.tf = stg 환경의 리소스 생성
- backend.tf = backend로 Azure Storage Account와 연결하여, .tfstate 파일 저장
- data_src.tf = 인증에 필요한 인증 정보를 Azure Key Vault의 키:값 데이터 참조
- AKS 클러스터(1.20.7)

# CMD
terraform init       - 백엔드 초기화, 플로그인, 모듈 설치
terraform validate   - 문법검사
terraform plan       - 변경사항 체크
terraform apply      - 인프라 적용
terraform destroy    - 리소스 삭제

# Files
thira_prd_conf.tfvars- 변수값 재정의
main_stg.tf          - 리소스 생성
backend.tf           - 백엔드 연결(Azure Storage Account)
data_src.tf          - 외부 데이터 소스 참조
outputs.tf           - 출력 변수 정의
provider.tf          - 외부 서비스와 연결(Azure)
variable.tf          - 입력 변수 정의

# GitHub Actions
- Terraform(IaC) Deploy to Azure Workflow
1) Checkout           - GitHub Source Checkout
2) Setup Terraform    - Terraform CLI 설치
3) Terraform Init     - 백엔드 초기화, 프로그인, 모듈 설치
4) Terraform Validate - Trraform 문법 검사
5) Terraform Plan     - 프로비저닝할 인프라 계획 검토
6) Terraform Apply    - 인프라 프로비저닝