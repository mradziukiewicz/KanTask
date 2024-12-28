"""
URL configuration for KanTask project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path

#import all apps here
from authentication import views

urlpatterns = [
    path('admin/', admin.site.urls),  # default admin page
    path('login/', views.login_view, name='login'),  # poprawione odwołanie do login_view
    path('projects/', views.project_list, name='project_list'),
    path('projects/<int:project_id>/', views.project_detail, name='project_detail'),
    path('tasks/<int:task_id>/', views.task_detail, name='task_detail'),
    path('kanban/', views.kanban_board, name='kanban_board'),
    path('update_task_status/<int:task_id>/<str:status>/', views.update_task_status, name='update_task_status'),

]
