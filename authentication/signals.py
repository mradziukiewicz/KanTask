# authentication/signals.py
from django.db.models.signals import post_migrate
from django.dispatch import receiver
from django.contrib.auth.models import Group, Permission
from django.contrib.contenttypes.models import ContentType
from .models import Task

@receiver(post_migrate)
def create_user_groups(sender, **kwargs):
    # Create groups
    customer_group, created = Group.objects.get_or_create(name='customer')
    manager_group, created = Group.objects.get_or_create(name='manager')
    engineer_group, created = Group.objects.get_or_create(name='engineer')

    # Assign permissions to groups
    content_type = ContentType.objects.get_for_model(Task)
    permissions = Permission.objects.filter(content_type=content_type)

    for perm in permissions:
        if perm.codename in ['add_comment', 'view_project']:
            customer_group.permissions.add(perm)
        if perm.codename in ['add_task', 'change_task', 'delete_comment']:
            manager_group.permissions.add(perm)
        if perm.codename in ['change_task', 'add_comment']:
            engineer_group.permissions.add(perm)