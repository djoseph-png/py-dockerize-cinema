import time
from django.core.management.base import BaseCommand
from django.db import connections
from django.db.utils import OperationalError


class Command(BaseCommand):
    help = "Aguarda o banco de dados ficar disponível."  # noqa: VNE003

    def handle(self, *args, **options):
        self.stdout.write("Esperando o banco de dados ficar disponível...")
        attempt = 0
        while True:
            try:
                connections["default"].cursor()  # força conexão
                break
            except OperationalError:
                attempt += 1
                self.stdout.write(f"DB indisponível, tentativa {attempt}...")
                time.sleep(1)
        self.stdout.write(self.style.SUCCESS("Banco de dados disponível!"))
