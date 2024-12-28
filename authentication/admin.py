from django import forms
from django.contrib import admin
from .models import Project, Task, Comment
from django.contrib.auth.models import User

class ProjectAdminForm(forms.ModelForm):
    owner = forms.ModelChoiceField(queryset=User.objects.all(), required=True)

    class Meta:
        model = Project
        fields = '__all__'

class ProjectAdmin(admin.ModelAdmin):
    form = ProjectAdminForm
    list_display = ('name', 'description', 'owner')
    search_fields = ('name', 'description')
    list_filter = ('owner',)

class TaskAdmin(admin.ModelAdmin):
    list_display = ['subject', 'status', 'priority', 'due_date', 'assigned_user', 'completion_percentage']
    search_fields = ['subject', 'description']
    list_filter = ['status', 'priority', 'due_date', 'assigned_user']

class CommentAdmin(admin.ModelAdmin):
    list_display = ('task', 'author', 'created_at')
    search_fields = ('content',)
    list_filter = ('created_at', 'author')

admin.site.register(Project, ProjectAdmin)
admin.site.register(Task, TaskAdmin)
admin.site.register(Comment, CommentAdmin)
