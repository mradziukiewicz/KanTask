# forms.py
from django import forms
from .models import Comment, Task, User, Project
from datetime import timedelta


class CommentForm(forms.ModelForm):
    class Meta:
        model = Comment
        fields = ['content']

class ProjectAdminForm(forms.ModelForm):
    owner = forms.ModelChoiceField(queryset=User.objects.filter(groups__name='manager'), required=True)
    customer = forms.ModelChoiceField(queryset=User.objects.filter(groups__name='customer'), required=True)

    class Meta:
        model = Project
        fields = '__all__'

class TaskForm(forms.ModelForm):
    assigned_user = forms.ModelChoiceField(queryset=User.objects.filter(groups__name='engineer'), required=True)

    class Meta:
        model = Task
        fields = '__all__'