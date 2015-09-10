from django.shortcuts import render, get_object_or_404
from ernesto.core.models import Dashboard


def view_dashboard(request, dashboard_id):
    dashboard = get_object_or_404(Dashboard, pk=dashboard_id)
    return render(request, 'dashboard.html', context=dict(
        dashboard=dashboard,
    ))
