# -*- coding: utf-8 -*-
# Generated by Django 1.11.5 on 2018-06-28 16:52


from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('enterprise_data', '0008_auto_20180614_0108'),
    ]

    operations = [
        migrations.RenameField(
            model_name='enterpriseenrollment',
            old_name='final_grade',
            new_name='current_grade',
        ),
        migrations.AddField(
            model_name='enterpriseenrollment',
            name='offer',
            field=models.CharField(max_length=128, null=True),
        ),
    ]
