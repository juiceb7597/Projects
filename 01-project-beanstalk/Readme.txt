#ap-northeast-1 도쿄 리전 기준입니다.

배포방법


1.Django 설정

devsearch-project/에서 진행
desearch/setting.py
line 16. 허용 주소 설정
line 181-182. 이메일 설정
line 203-205. S3버킷 설정

projects/management/commands/createsu.py
line 8-9. superuser 설정

devsearch-project 내 모든 파일을 django.zip으로 압축




2.vpc 구성

terraformVPC/에서 terraform 사용




3.Beanstalk 배포 설정

새 환경 생성
웹 서버 환경
애플리케이션 이름 입력
환경이름 입력
도메인 입력 (devsearch/setting.py내 ALLOWED_HOSTS에 설정한 값)
플랫폼 설정 Python,Python3.8
애플리케이션 코드 - 코드 업로드 - django.zip
추가 옵션 구성

사전 설정 - 고가용성
용량 - 인스턴스 최소2 최대4
로드 밸런스 - alb
보안 - YourKeyPair
데이터베이스 - 엔진 postgres, 사용자 이름, 암호 설정, 고가용성
네트워크 - vpc('jp-vpc'), 로드밸런서 서브넷 'public-1a-elb', 'public-1c-elb'
                         인스턴스 서브넷 'private-1a-instance', 'private-1c-instance'
                         데이터베이스 서브넷 'private-1a-database', 'private-1c-database'
환경 생성
환경 생성 후
구성 - 소프트웨어 - 편집
환경 속성 - 추가
RDS_DB_NAME = ebdb
RDS_HOSTNAME = RDS에 생성된 인스턴스의 endpoint
RDS_USER_NAME = 데이터베이스 생성 때 만든 사용자 이름
RDS_PASSWORD = 데이터베이스 생성 때 만든 암호
RDS_PORT = 5432




4.Route 53 (Optional)
도메인 등록 
등록된 도메인으로 호스팅 영역 생성
레코드 생성 - 단순 레코드 정의 - 레코드 이름 www- 레코드 영역 A 
-엔트포인트 Beanstalk 별칭 - 도쿄 리전 - 환경 선택 -단순 레코드 정의 




5.Http to https Redirection (Optional)
Certificatre manager - 인증서 요청 - 퍼블릭 인증서 요청
- 완전히 정규화된 도메인 이름 *.YourRoute53DomainName
- 요청 - 인증서 ID 클릭 - 도메인 - Route53에서 레코드 생성
- 레코드 생성 - 호스팅영역에서 CNAME 생성된 후 발급 완료
Beanstalk - 환경 - 구성 - 로드밸런서 - 편집 - 리스너 Port443 HTTPS 등록(올바른 SSL정책)
- 적용
Ec2 콘솔 - 로드밸런서 - 리스너 http:80 편집 - 기본 작업 - 리디렉션 - HTTPS:443 - 상태 코드 301- 저장




#vpc 구성도

vpc 생성
이름     cider
'jp-vpc' 10.0.0.0/16

subnet 생성('jp-vpc')
이름                    cider         region
'public-1a-elb'         10.0.10.0/24  ap-northeast-1a
'public-1c-elb'         10.0.20.0/24  ap-northeast-1c
'private-1a-instance'   10.0.30.0/24  ap-northeast-1a
'private-1c-instance'   10.0.40.0/24  ap-northeast-1c
'private-1a-database'   10.0.50.0/24  ap-northeast-1a
'private-1c-database'   10.0.60.0/24  ap-northeast-1c

igw 생성 
이름       vpc
'jp-igw' 'jp-vpc'에 연결

nat 생성
이름            서브넷
'nat-1a-gw'  'public-1a-elb'에 연결 , EIP할당
'nat-1c-gw'  'public-1c-elb'에 연결 , EIP할당

라우팅 테이블 생성
이름                     대상        cider
'jp-public-routes'       'local'     10.0.0.0/16
                         'jp-igw'    0.0.0.0/0
'jp-private-1a-routes'   'local'     10.0.0.0/16
                         'nat-1a-gw' 0.0.0.0/0
'jp-private-1c-routes'   'local'     10.0.0.0/16
                         'nat-1c-gw' 0.0.0.0/0

라우팅 테이블 서브넷 할당
이름                     대상    
'jp-public-routes'       'public-1a-elb' 
                         'public-1c-elb'
'jp-private-1a-routes'   'private-1a-instance'
                         'private-1a-database'
'jp-private-1c-routes'   'private-1c-instance'     
                         'private-1c-database'





#참고 강의

https://www.udemy.com/course/python-django-2021-complete-course/                               -Django
https://www.udemy.com/course/aws-elastic-beanstalk-master-class/                               -Beanstalk
https://www.udemy.com/course/terraform-on-aws-with-sre-iac-devops-real-world-demos/            -Terraform





