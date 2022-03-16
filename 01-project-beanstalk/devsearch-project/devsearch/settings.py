from datetime import timedelta
from pathlib import Path
import os
from re import X
BASE_DIR = Path(__file__).resolve().parent.parent



SECRET_KEY = 'django-insecure--4iws!uc#2j2cwb2llj!)k&lw3=+zy^2cxqrdj2h=nai8eiq*8'

DEBUG = True

#허용 주소
# Beanstalk URL은 환경 생성 시 '임의 도메인.ap-northeast-1.elasticbeanstalk.com'로 생성되니 넣을 값을 미리 설정해요.
# 예)test-django-project.ap-northeast-1.elasticbeanstalk.com
ALLOWED_HOSTS = ['localhost', '127.0.0.1','YourBeanstalkDomain.ap-northeast-1.elasticbeanstalk.com','.YourRoute53Domain.com']

x="10.0.10."
y="10.0.20."
z="10.0.30."
v="10.0.40."

for i in range(256):
    ALLOWED_HOSTS.append(x+str(i))
    ALLOWED_HOSTS.append(y+str(i))
    ALLOWED_HOSTS.append(z+str(i))
    ALLOWED_HOSTS.append(v+str(i))
    


INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    'projects.apps.ProjectsConfig',
    'users.apps.UsersConfig',

    'rest_framework',
    'corsheaders',
    'storages'

]

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    )
}

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(days=1),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=30),
    'ROTATE_REFRESH_TOKENS': False,
    'BLACKLIST_AFTER_ROTATION': True,
    'UPDATE_LAST_LOGIN': False,

    'ALGORITHM': 'HS256',

    'VERIFYING_KEY': None,
    'AUDIENCE': None,
    'ISSUER': None,

    'AUTH_HEADER_TYPES': ('Bearer',),
    'AUTH_HEADER_NAME': 'HTTP_AUTHORIZATION',
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',
    'USER_AUTHENTICATION_RULE': 'rest_framework_simplejwt.authentication.default_user_authentication_rule',

    'AUTH_TOKEN_CLASSES': ('rest_framework_simplejwt.tokens.AccessToken',),
    'TOKEN_TYPE_CLAIM': 'token_type',

    'JTI_CLAIM': 'jti',

    'SLIDING_TOKEN_REFRESH_EXP_CLAIM': 'refresh_exp',
    'SLIDING_TOKEN_LIFETIME': timedelta(minutes=5),
    'SLIDING_TOKEN_REFRESH_LIFETIME': timedelta(days=1),
}


MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',

    'django.middleware.security.SecurityMiddleware',

    'whitenoise.middleware.WhiteNoiseMiddleware',

    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'devsearch.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [
            os.path.join(BASE_DIR, 'templates'),
        ],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'devsearch.wsgi.application'

#데이터베이스 환경설정
#Beanstalk 내 환경 변수 설정으로 자동으로 값이 입력됩니다.
if 'RDS_HOSTNAME' in os.environ:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': os.environ['RDS_DB_NAME'],
            'USER': os.environ['RDS_USERNAME'],
            'PASSWORD': os.environ['RDS_PASSWORD'],
            'HOST': os.environ['RDS_HOSTNAME'],
            'PORT': os.environ['RDS_PORT'],
        }
    }

# 외부 데이터베이스의 경우
# DATABASES = {
#     'default': {
#         'ENGINE': 'django.db.backends.postgresql',
#         'NAME': 'YourExternalDatabaseName',
#         'USER': 'YourExternalDatabaseUserName',
#         'PASSWORD': 'YourExternalDatabasePassword',
#         'HOST': 'YourExternalDatabaseEndpoint',
#         'POST': '5432',
#     }
# }


AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_L10N = True

USE_TZ = True

CORS_ALLOW_ALL_ORIGINS = True

# 알림받을 이메일 설정
# google계정에서 - 보안 수준이 낮은 앱에 대한 액세스 허용
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.gmail.com'
EMAIL_PORT = 587
EMAIL_USE_TLS = True
EMAIL_HOST_USER = 'YourEmail@gmail.com'
EMAIL_HOST_PASSWORD = 'YourAppAccessPassword'


STATIC_URL = '/static/'
MEDIA_URL = '/images/'

STATICFILES_DIRS = [
    BASE_DIR / 'static'
]

MEDIA_ROOT = os.path.join(BASE_DIR, 'static/images')
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

DEFAULT_FILE_STORAGE = 'storages.backends.s3boto3.S3Boto3Storage'

AWS_QUERYSTRING_AUTH = False
AWS_S3_FILE_OVERWRITE = False

# StaticFiles의 s3 버킷 경로 설정
AWS_ACCESS_KEY_ID = 'YourAWSUSerAccessKeyID'
AWS_SECRET_ACCESS_KEY = 'YourAWSUserAccessKey'
AWS_STORAGE_BUCKET_NAME = 'YourAWSS3BucketName'

#퍼블릭 엑세스가 허용된 S3버킷이여야 합니다.
#버킷 권한 설정
# {
#     "Version": "2008-10-17",
#     "Statement": [
#         {
#             "Sid": "AllowPublicRead",
#             "Effect": "Allow",
#             "Principal": {
#                 "AWS": "*"
#             },
#             "Action": "s3:GetObject",
#             "Resource": "arn:aws:s3:::YourAWSS3BucketName/*"
#         }
#     ]
# }



if os.getcwd() == '/app':
    DEBUG = False
