from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import authenticate, login as auth_login
from django.http import JsonResponse
from .models import Project, Task,Comment,Incident
from .forms import CommentForm, TaskForm, IncidentReportForm
from django.utils import timezone
from django.contrib.auth.decorators import user_passes_test
from django.contrib import messages
from django.db.models import Q
from django.contrib.auth.decorators import login_required

def is_superuser_or_owner(user, project):
    return user.is_superuser or user == project.owner

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



# authentication/views.py

# authentication/views.py


def project_detail(request, project_id):
    project = get_object_or_404(Project, id=project_id)
    if not is_superuser_or_owner(request.user, project) and request.user != project.customer and not project.tasks.filter(assigned_user=request.user).exists():
        return redirect('project_list')

    tasks = Task.objects.filter(project=project, parent_task__isnull=True)
    subtasks = Task.objects.filter(project=project, parent_task__isnull=False)
    total_tasks = tasks.count()
    completed_tasks = tasks.filter(status='Completed').count()
    completion_rate = round((completed_tasks / total_tasks * 100), 2) if total_tasks > 0 else 0
    search_query = request.GET.get('search', '')

    if search_query:
        tasks = tasks.filter(
            Q(subject__icontains=search_query) | Q(id__icontains=search_query)
        )
        subtasks = subtasks.filter(
            Q(subject__icontains=search_query) | Q(id__icontains=search_query)
        )

    return render(request, 'project_detail.html', {
        'project': project,
        'tasks': tasks,
        'subtasks': subtasks,
        'completion_rate': completion_rate,
    })

# authentication/views.py

def task_detail(request, task_id):
    task = get_object_or_404(Task, id=task_id)
    if not is_superuser_or_owner(request.user, task.project) and request.user != task.assigned_user and request.user != task.project.customer:
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


# authentication/views.py

def update_task_status(request, task_id, status):
    task = get_object_or_404(Task, id=task_id)

    # Prevent customers from changing the task status
    if request.user.is_customer():
        messages.error(request, 'Customers are not allowed to change the task status.')
        return redirect('task_detail', task_id=task.id)

    if request.method == 'POST':
        solution = request.POST.get('solution', '')
        time_spent = request.POST.get('time_spent', '')

        if status == 'Completed':
            if not solution:
                messages.error(request, 'Solution is required to complete the task.')
                return redirect('task_detail', task_id=task.id)
            if not time_spent:
                messages.error(request, 'Time spent is required to complete the task.')
                return redirect('task_detail', task_id=task.id)
            task.solution = solution
            task.time_spent = time_spent

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

    # Add auto-comment
    comment_content = f'Task status changed to {status} by {request.user.username}.'
    Comment.objects.create(task=task, author=request.user, content=comment_content)

    return redirect(request.META.get('HTTP_REFERER', 'task_detail'), task_id=task.id)



@user_passes_test(lambda u: u.is_superuser or u.is_authenticated)
def add_task(request, project_id):
    project = get_object_or_404(Project, id=project_id)
    tasks = Task.objects.filter(project=project)

    if not is_superuser_or_owner(request.user, project):
        return redirect('project_detail', project_id=project.id)

    if request.method == 'POST':
        form = TaskForm(request.POST, project=project)
        if form.is_valid():
            new_task = form.save(commit=False)
            new_task.project = project
            parent_task_id = request.POST.get('parent_task')
            if parent_task_id:
                new_task.parent_task = Task.objects.get(id=parent_task_id)
            new_task.save()
            return redirect('project_detail', project_id=project.id)
    else:
        form = TaskForm(project=project)

    return render(request, 'add_task.html', {'form': form, 'project': project, 'tasks': tasks})


# authentication/views.py

@user_passes_test(lambda u: u.is_superuser or u.is_authenticated)
def delete_task(request, project_id, task_id):
    project = get_object_or_404(Project, id=project_id)
    task = get_object_or_404(Task, id=task_id, project=project)

    if not is_superuser_or_owner(request.user, project):
        return redirect('project_detail', project_id=project.id)

    if request.method == 'POST':
        task.delete()
        return redirect('project_detail', project_id=project.id)

    return render(request, 'delete_task.html', {'task': task, 'project': project})

# authentication/views.py

@user_passes_test(lambda u: u.is_superuser or u.is_authenticated)
def edit_task(request, project_id, task_id):
    project = get_object_or_404(Project, id=project_id)
    task = get_object_or_404(Task, id=task_id, project=project)

    if not is_superuser_or_owner(request.user, project):
        return redirect('project_detail', project_id=project.id)

    if request.method == 'POST':
        form = TaskForm(request.POST, instance=task, project=project)
        if form.is_valid():
            form.save()
            return redirect('project_detail', project_id=project.id)
    else:
        form = TaskForm(instance=task, project=project)

    return render(request, 'edit_task.html', {'form': form, 'project': project, 'task': task})


@login_required
def home(request):
    projects = Project.objects.all()
    comments = Comment.objects.order_by('-created_at')[:5]

    context = {
        'projects': projects,
        'comments': comments,
    }
    return render(request, 'home.html', context)

@user_passes_test(lambda u: u.is_superuser or u.is_customer)
def report_incident(request):
    if request.method == 'POST':
        form = IncidentReportForm(request.POST)
        if form.is_valid():
            incident = form.save(commit=False)
            incident.created_by = request.user
            incident.save()
            return redirect('home')
    else:
        form = IncidentReportForm()

    return render(request, 'report_incident.html', {'form': form})

@user_passes_test(lambda u: u.is_superuser or u.is_manager())
def reported_errors(request):
    incidents = Incident.objects.all()
    return render(request, 'reported_errors.html', {'incidents': incidents})