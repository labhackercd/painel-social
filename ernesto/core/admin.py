from django.contrib import admin
from . import models


class DashboardWidgetInline(admin.StackedInline):
    model = models.Widget


class DashboardAdmin(admin.ModelAdmin):
    inlines = (
        DashboardWidgetInline
    )


admin.site.register(models.Dashboard, DashboardAdmin)
