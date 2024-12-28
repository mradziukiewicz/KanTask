from django import template

register = template.Library()

@register.inclusion_tag('task_tree.html')
def render_task_tree(task):
    return {'task': task}