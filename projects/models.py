from django.db import models

class Project(models.Model):
    name = models.CharField(max_length=20)
    description = models.TextField(blank=True, null=True)
    completion_percentage = models.DecimalField(max_digits=5, decimal_places=2)

    def __str__(self):
        return self.name
