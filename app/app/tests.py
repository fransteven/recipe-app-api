from django.test import SimpleTestCase
from app import calc

class CalcTest(SimpleTestCase):
    def test_add_numbers(self):
        res = calc.sum(6,5)
        self.assertEqual(res,11)

    def test_substract(self):
        res  = calc.substract(10,15)
        self.assertEqual(res,5)