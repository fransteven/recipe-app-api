"""
Test custom Django management commands.
"""
from unittest.mock import patch
from psycopg2 import OperationalError as Psycopg2Error
from django.core.management import call_command
from django.db.utils import OperationalError
from django.test import SimpleTestCase

@patch('core.management.commands.wait_for_db.Command.check')
class CommandTest(SimpleTestCase):
    """Test commands."""
    def test_wait_for_db_ready(self,patched_check):
        #Simula que la base de datos está lista devolviendo True al llamar a Command.check.
        patched_check.return_value = True
        #Llama al comando personalizado wait_for_db.
        #Como el método check devuelve True, el comando debería completarse inmediatamente.
        call_command('wait_for_db')
        #Verifica que el método check se haya llamado una sola vez con el argumento database=['default'] (aunque esto contiene un error; debe ser databases=['default']).
        patched_check.assert_called_once_with(databases=['default'])

    @patch('time.sleep')
    def test_wait_for_db_delay(self,patched_sleep,patched_check):
        """Test waiting for database when getting OperationalError."""
        #Simula que las primeras dos llamadas al método check lanzan un error de tipo Psycopg2Error (error específico de PostgreSQL).
        #Las siguientes tres llamadas lanzan un OperationalError (error general de conexión a la base de datos).
        #Finalmente, la sexta llamada devuelve True, indicando que la base de datos está lista.
        patched_check.side_effect = [Psycopg2Error] * 2 + \
                                    [OperationalError] * 3 + [True]
        
        #Llama al comando wait_for_db.
        #El comando debería manejar las excepciones simuladas y seguir intentando hasta que el método check devuelva True.
        call_command('wait_for_db')
        #Verifica que el método check se haya llamado 6 veces (2 errores de PostgreSQL, 3 errores generales y 1 éxito).
        self.assertEqual(patched_check.call_count,6)
        #Verifica que en la última llamada, el método check haya sido llamado con el argumento database=['default'] (que debe corregirse a databases=['default']).
        patched_check.assert_called_with(databases=['default'])