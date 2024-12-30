from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import authenticate, login as auth_login
from django.http import JsonResponse
from .models import Project, Task
from .forms import CommentForm
from django.utils import timezone
from django.contrib.auth.decorators import user_passes_test
from django.contrib import messages

def is_customer(user):
    return user.is_customer()

def is_manager(user):
    return user.is_manager()

def is_engineer(user):
    return user.is_engineer()

@user_passes_test(is_customer)
def customer_view(request):
    # Customer-specific view logic
    pass

@user_passes_test(is_manager)
def manager_view(request):
    # Manager-specific view logic
    pass

@user_passes_test(is_engineer)
def engineer_view(request):
    # Engineer-specific view logic
    pass


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

# authentication/views.py

# authentication/views.py

def project_list(request):
    if request.user.is_superuser:
        projects = Project.objects.all()
    elif request.user.is_manager():
        projects = Project.objects.filter(owner=request.user)
    elif request.user.is_customer():
        projects = Project.objects.filter(customer=request.user)
    elif request.user.is_engineer():
        projects = Project.objects.filter(tasks__assigned_user=request.user).distinct()
    else:
        projects = Project.objects.none()
    return render(request, 'project_list.html', {'projects': projects})


def project_detail(request, project_id):
    project = get_object_or_404(Project, id=project_id)
    if not request.user.is_superuser and request.user != project.owner and request.user != project.customer and not project.tasks.filter(assigned_user=request.user).exists():
        return redirect('project_list')

    tasks = Task.objects.filter(project=project, parent_task__isnull=True)
    total_tasks = tasks.count()
    completed_tasks = tasks.filter(status='Completed').count()
    completion_rate = (completed_tasks / total_tasks * 100) if total_tasks > 0 else 0

    return render(request, 'project_detail.html', {
        'project': project,
        'tasks': tasks,
        'completion_rate': completion_rate,
    })

def task_detail(request, task_id):
    task = get_object_or_404(Task, id=task_id)
    if not request.user.is_superuser and request.user != task.assigned_user and request.user != task.project.owner and request.user != task.project.customer:
        return redirect('project_detail', project_id=task.project.id)

    subtasks = task.subtasks.all().distinct()  # Ensure unique subtasks
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
    })


# authentication/views.py

def kanban_board(request):
    if request.user.is_engineer():
        tasks = Task.objects.filter(assigned_user=request.user)
    elif request.user.is_manager():
        tasks = Task.objects.filter(project__owner=request.user)
    elif request.user.is_customer():
        tasks = Task.objects.filter(project__customer=request.user)
    else:
        tasks = Task.objects.none()
    return render(request, 'kanban_board.html', {'tasks': tasks})


def update_task_status(request, task_id, status):
    task = get_object_or_404(Task, id=task_id)

    # Prevent customers from changing the task status
    if request.user.is_customer():
        messages.error(request, 'Customers are not allowed to change the task status.')
        return redirect('task_detail', task_id=task.id)

    if request.method == 'POST':
        solution = request.POST.get('solution', '')

        if status == 'Completed' and not solution:
            return JsonResponse({'error': 'Solution is required to complete the task.'}, status=400)

        if status == 'Completed':
            task.solution = solution

    # Allow manual status change if the task has no subtasks
    if not task.subtasks.exists():
        task.status = status
    else:
        # Automatically update the parent task status based on subtasks
        if status == 'In Progress':
            task.status = 'In Progress'
        elif status == 'Completed' and all(subtask.status == 'Completed' for subtask in task.subtasks.all()):
            task.status = 'Completed'
        else:
            task.status = 'Pending'

    # Check if the task is completed after the SLA deadline
    if status == 'Completed' and timezone.now() > task.sla_deadline:
        task.resolved_after_deadline = True

    task.save()

    # Update parent task status if necessary
    if task.parent_task:
        parent_task = task.parent_task
        if status == 'In Progress':
            parent_task.status = 'In Progress'
        elif status == 'Completed' and all(subtask.status == 'Completed' for subtask in parent_task.subtasks.all()):
            parent_task.status = 'Completed'
        else:
            parent_task.status = 'In Progress'
        parent_task.save()

    return redirect(request.META.get('HTTP_REFERER', 'task_detail'), task_id=task.id)
