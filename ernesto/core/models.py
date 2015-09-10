from django.db import models


class Dashboard(models.Model):
    title = models.CharField(max_length=255)


class Widget(models.Model):
    title = models.CharField(max_length=255)
    component = models.CharField(max_length=255)
    data_source = models.CharField(max_length=255)
