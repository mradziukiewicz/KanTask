# Generated by Django 5.1.3 on 2024-12-29 18:29

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('authentication', '0004_remove_task_due_date'),
    ]

    operations = [
        migrations.AlterField(
            model_name='task',
            name='work_time',
            field=models.IntegerField(blank=True, default=0, null=True),
        ),
    ]
