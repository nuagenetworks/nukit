# NUKit

## Introduction

NUKit is an application framework that provides the user with a set of classes and tools that will make very easy to build full featured Cappuccino Front End for any Garuda-type backed server.

At a glance, NUKit will help you:

- Create a new application
- Display paginated, filterable views of the remote model
- Auto bind the Model attributes in edition views
- Support for push notifications and live update
- Support for Model validation
- Provides advanced controls, like an IPv4/IPv6/MAC Text field
- Provides no pain build scripts for building, pressing, flattening etc
- Provides an one command to create a Docker container for your application

NUKit provides a modular way to create and assemble different views to show one or objects of the model, and a way to load sub modules to show the children of a particular object.


## Relation with Monolithe and Garuda

NUKit will help you build a front end for any kind of Garuda server loading a Monolithe generated SDK. The process to create an new application is fairly simple:

- create a Monolithe Specification
- generate a Python SDK using Monolithe based on the same Specification
- load the generated into a Garuda server
- generate a Objective-J using Monolithe based on the same Specification
- Create a new NUKit application
- Use the generated Objective-J SDK to represent your model.
- Develop the different views
- Enjoy your life


## Concepts

### NUModule and NUModuleContext

The core concepts of NUKit relies on the class NUModule. It represents a view controller dedicated to show a particular remote object or a list of remote objects based on a parent. NUModule will be able to manage all CRUD operations on those objects using one (or more) NUModuleContexts. Usually, list of objects are shown in a CPTableView or CPOutlineView. When user double clicks on one of them, the NUModule will open a CPPopover containing auto bound controls needed to edit the object properties. When a user just selects one the object, according to the NUModule configuration, it will load one or more sub NUModule to display the the children of that particular object. All submodules will be shown as a tab in a TNTabView managed by the parent NUModule.

For example, if we have a Model representing a Todo List that contains Lists that contains Tasks, you can have a NUModule to display, create and edit the Lists. When the user selects a List, a sub module will load the Tasks in that particular list and provides CRUD operations on them.

There are different NUModule flavors:

- NUModule: listing module
- NUModuleSelfParent: single object edition module
- NUAssignationModule: module used to work on relationship of type `member`
- NUModuleItemized: A module that will just show a list of submodules
- NUModuleSingleObjectShower: A generic module to show a single object
- NUModuleMultipleObjectsShower: A generic module to a list of objects
- NUObjectsChooser: A module used by other modules to present a list of objects

### Object Associators

TODO

### DataView Registration

TODO

### Hierarchy Controllers

TODO

### Skins

TODO


## Example

You can find a comprehensive example [in the example directory](Example/README.md).
