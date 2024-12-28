# forms.py
from django import forms
from .models import Comment, Task
from datetime import timedelta

class CommentForm(forms.ModelForm):
    class Meta:
        model = Comment
        fields = ['content']
class TaskForm(forms.ModelForm):
    work_time = forms.DurationField(initial=timedelta())

    class Meta:
        model = Task
        fields = ['subject', 'description', 'status', 'priority', 'due_date', 'assigned_user', 'completion_percentage', 'work_time', 'parent_task']
