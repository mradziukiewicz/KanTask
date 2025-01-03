from django.utils import timezone
from django.contrib.auth.models import AbstractUser, Group, Permission
from django.db import models


class User(AbstractUser):
    groups = models.ManyToManyField(
        Group,
        related_name='authentication_user_set',  # Add related_name to avoid conflict
        blank=True,
        help_text='The groups this user belongs to.',
        verbose_name='groups',
    )
    user_permissions = models.ManyToManyField(
        Permission,
        related_name='authentication_user_permissions_set',  # Add related_name to avoid conflict
        blank=True,
        help_text='Specific permissions for this user.',
        verbose_name='user permissions',
    )

    def is_customer(self):
        return self.groups.filter(name='customer').exists()

    def is_manager(self):
        return self.groups.filter(name='manager').exists()

    def is_engineer(self):
        return self.groups.filter(name='engineer').exists()

class Project(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField()
    owner = models.ForeignKey(User, on_delete=models.CASCADE, related_name='owned_projects')
    customer = models.ForeignKey(User, on_delete=models.CASCADE, related_name='customer_projects', default=1)
    def save(self, *args, **kwargs):
        if not self.owner.is_manager():
            raise ValueError("The owner of the project must be a manager.")
        if not self.customer.is_customer():
            raise ValueError("The customer of the project must be a customer.")
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name

# authentication/models.py

class Task(models.Model):
    STATUS_CHOICES = [
        ('Pending', 'Pending'),
        ('In Progress', 'In Progress'),
        ('Completed', 'Completed'),
    ]

    PRIORITY_CHOICES = [
        ('low', 'Low'),
        ('normal', 'Normal'),
        ('high', 'High'),
    ]

    subject = models.CharField(max_length=255)
    description = models.TextField()
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='Pending')
    priority = models.CharField(max_length=20, choices=PRIORITY_CHOICES, default='normal')
    assigned_user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='tasks')
    created_at = models.DateTimeField(default=timezone.now)
    closed_at = models.DateTimeField(null=True, blank=True)
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name='tasks')
    completion_percentage = models.FloatField(default=0.0)
    parent_task = models.ForeignKey('self', on_delete=models.CASCADE, null=True, blank=True, related_name='subtasks')
    sla_deadline = models.DateTimeField(null=True, blank=True)
    resolved_after_deadline = models.BooleanField(default=False)
    solution = models.TextField(null=True, blank=True)
    time_spent = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)

    def save(self, *args, **kwargs):
        if self.assigned_user and not self.assigned_user.groups.filter(name='engineer').exists():
            raise ValueError("The assigned user must be an engineer.")
        if self.status == 'Completed' and self.sla_deadline and timezone.now() > self.sla_deadline:
            self.resolved_after_deadline = True
        super().save(*args, **kwargs)

    def __str__(self):
        return self.subject


class Comment(models.Model):
    task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name='comments', null=True, blank=True)
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'Comment by {self.author} on {self.created_at}'