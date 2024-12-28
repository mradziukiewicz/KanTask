from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import authenticate, login as auth_login
from django.http import JsonResponse
from .models import Project, Task
from .forms import CommentForm
from datetime import timedelta
def login_view(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        user = authenticate(request, username=username, password=password)
        if user is not None:
            auth_login(request, user)
            return JsonResponse({'success': True})
        else:
            return JsonResponse({'success': False, 'error': 'Invalid credentials'})
    return render(request, 'login.html')

def project_list(request):
    projects = Project.objects.all()
    return render(request, 'project_list.html', {'projects': projects})

def project_detail(request, project_id):
    project = get_object_or_404(Project, id=project_id)
    tasks = Task.objects.filter(project=project, parent_task__isnull=True)
    return render(request, 'project_detail.html', {
        'project': project,
        'tasks': tasks,
    })

def task_detail(request, task_id):
    task = get_object_or_404(Task, id=task_id)
    subtasks = task.subtasks.all().distinct()  # Ensure unique subtasks
    # Convert seconds to timedelta
    duration_seconds = task.work_time
    duration = timedelta(seconds=duration_seconds)

    subtasks = task.subtasks.all().distinct()  # Ensure unique subtasks
    comments = task.comments.all()
    comments = task.comments.all()
    if request.method == 'POST':
        form = CommentForm(request.POST)
        if form.is_valid():
            comment = form.save(commit=False)
            comment.task = task
            comment.author = request.user
            comment.save()
            return redirect('task_detail', task_id=task.id)
    else:
        form = CommentForm()
    return render(request, 'task_detail.html', {
        'task': task,
        'subtasks': subtasks,
        'comments': comments,
        'form': form,
        'duration': duration,
    })


def kanban_board(request):
    tasks = Task.objects.all()
    return render(request, 'kanban_board.html', {'tasks': tasks})

def update_task_status(request, task_id, status):
    task = get_object_or_404(Task, id=task_id)
    task.status = status
    task.save()
    return redirect('kanban_board')
