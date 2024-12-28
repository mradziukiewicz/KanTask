from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone
from datetime import timedelta

class Project(models.Model):
    name = models.CharField(max_length=255)
    description = models.TextField()
    owner = models.ForeignKey(User, on_delete=models.CASCADE)

    def __str__(self):
        return self.name

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
    due_date = models.DateField()
    assigned_user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='tasks')
    created_at = models.DateTimeField(default=timezone.now)
    closed_at = models.DateTimeField(null=True, blank=True)
    project = models.ForeignKey(Project, on_delete=models.CASCADE, related_name='tasks')
    completion_percentage = models.FloatField(default=0.0)
    work_time = models.IntegerField(default=0)
    parent_task = models.ForeignKey('self', on_delete=models.CASCADE, null=True, blank=True, related_name='subtasks')

    def __str__(self):
        return self.subject

    def get_days_until_due(self):
        if self.due_date:
            time_difference = self.due_date - timezone.now().date()
            return time_difference.days
        return None

class Comment(models.Model):
    task = models.ForeignKey(Task, on_delete=models.CASCADE, related_name='comments', null=True, blank=True)
    author = models.ForeignKey(User, on_delete=models.CASCADE)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'Comment by {self.author} on {self.created_at}'