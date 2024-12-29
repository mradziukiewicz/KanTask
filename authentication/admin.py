from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.contrib.auth.forms import UserCreationForm, UserChangeForm

from .forms import TaskForm, ProjectAdminForm
from .models import User, Project, Task, Comment


class CustomUserCreationForm(UserCreationForm):
    class Meta:
        model = User
        fields = ('username', 'email', 'password1', 'password2')

class CustomUserChangeForm(UserChangeForm):
    class Meta:
        model = User
        fields = ('username', 'email', 'password', 'is_active', 'is_staff')

class CustomUserAdmin(BaseUserAdmin):
    add_form = CustomUserCreationForm
    form = CustomUserChangeForm
    model = User
    list_display = ('username', 'email', 'is_staff', 'is_active')
    list_filter = ('is_staff', 'is_active')
    fieldsets = (
        (None, {'fields': ('username', 'email', 'password')}),
        ('Permissions', {'fields': ('is_staff', 'is_active', 'groups', 'user_permissions')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('username', 'email', 'password1', 'password2', 'is_staff', 'is_active', 'groups', 'user_permissions'),
        }),
    )
    search_fields = ('username', 'email')
    ordering = ('username',)

admin.site.register(User, CustomUserAdmin)



class ProjectAdmin(admin.ModelAdmin):
    form = ProjectAdminForm
    list_display = ('name', 'description', 'owner', 'customer')
    search_fields = ('name', 'description')
    list_filter = ('owner', 'customer')

class TaskAdmin(admin.ModelAdmin):
    form = TaskForm
    list_display = ['subject', 'status', 'priority', 'assigned_user', 'completion_percentage']
    search_fields = ['subject', 'description']
    list_filter = ['status', 'priority', 'assigned_user']

class CommentAdmin(admin.ModelAdmin):
    list_display = ('task', 'author', 'created_at')
    search_fields = ('content',)
    list_filter = ('created_at', 'author')

admin.site.register(Project, ProjectAdmin)
admin.site.register(Task, TaskAdmin)
admin.site.register(Comment, CommentAdmin)