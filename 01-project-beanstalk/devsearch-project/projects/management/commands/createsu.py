from django.core.management.base import BaseCommand
from django.contrib.auth.models import User

# 인스턴스 실행 시 superuser 생성
class Command(BaseCommand):

    def handle(self, *args, **options):
        if not User.objects.filter(username="YourSuperuserUsername").exists():
            User.objects.create_superuser("YourSuperuserUsername", "YourSuperuserEmail", "YourSuperuserPassword")
