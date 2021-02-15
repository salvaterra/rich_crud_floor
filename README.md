# rich_crud_floor

Build rich CRUD models and views using Floor. Fully customizable, non-invasive, coupled view-model, relational entities with foreign key accessor. Inspired by Django.

## Goal

Go from this (text):

``#Person: String name;``

to a fully functional Flutter view: create, read, update and delete, including dropbox for related foreign key entities (Person.getKids() yields List<Kids>).

## Features

You can create your models in text file, and the generator will do the rest.

Generated classes can have (all customizable, each feature can be switched on or off):

- Primary key added by default (int id)
- Generic localized ui-friendly methods for labels (e.g. CreditScore.getName() returns "Credit Score" which can be used as the title of the CRUD view such as "Your Credit Score"). Supports multi language. Also available for field names.
- Is field visible in the UI? Allow hiding fields from the UI.
- Is field required in the UI? Allow validation in the form UI.
- Main field - allow folding similar models. Example: If you have Car and Boat instances and want to aggregate their usd value, you can set Car.value and Boat.value and get as CrudEntity.getMainValueFieldName()
- Relationship models - automatically creates relationship between models. A person who owns a dog can do Person.getDogs() which will return a Dog() entity.
- Unliking models - used for deletion of foreign key. If a Person no longer owns a dog it can do Person.unlinkRelated().