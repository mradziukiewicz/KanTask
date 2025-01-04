from django import forms
from django.contrib.admin.widgets import AdminDateWidget

from .models import Comment, Task, User, Project, Incident



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

class TaskAdminForm(forms.ModelForm):
    class Meta:
        model = Task
        fields = ['subject', 'description', 'priority', 'assigned_user', 'sla_deadline', 'status', 'parent_task']
        widgets = {
            'sla_deadline': AdminDateWidget(),
        }

class TaskForm(forms.ModelForm):
    class Meta:
        model = Task
        fields = ['subject', 'description', 'priority', 'assigned_user', 'sla_deadline', 'status', 'parent_task']
        widgets = {
            'sla_deadline': forms.DateInput(attrs={'type': 'date'}),
        }

    def __init__(self, *args, **kwargs):
        project = kwargs.pop('project', None)
        super(TaskForm, self).__init__(*args, **kwargs)
        if project:
            self.fields['parent_task'].queryset = Task.objects.filter(project=project)
        self.fields['assigned_user'].queryset = User.objects.filter(groups__name='Engineer')

class IncidentReportForm(forms.ModelForm):
    class Meta:
        model = Incident
        fields = ['title', 'description', 'project']