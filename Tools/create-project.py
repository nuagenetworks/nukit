#!/usr/bin/env python
import sys, os, argparse
import shutil
import jinja2

def _init_structure(prefix, args):
    """
    """
    if os.path.exists(prefix):
        shutil.rmtree(prefix)

    _write_code_folder(prefix, args.class_prefix, 'Associators')
    _write_code_folder(prefix, args.class_prefix, 'DataViews')
    _write_code_folder(prefix, args.class_prefix, 'Models')
    _write_code_folder(prefix, args.class_prefix, 'Transformers')
    _write_code_folder(prefix, args.class_prefix, 'ViewControllers')

    os.makedirs(os.path.join(prefix, 'Libraries'))
    os.makedirs(os.path.join(prefix, 'Resources', 'Branding'))

    _write_template('branding.js.tpl', os.path.join(prefix, 'Resources', 'Branding', 'branding.js'), app_name=args.name)
    _write_template('DataViewsLoader.j.tpl', os.path.join(prefix, 'DataViews', '%sDataViewLoader.j' % args.class_prefix), class_prefix=args.class_prefix)
    _write_template('index.html.tpl', os.path.join(prefix, 'index.html'), app_name=args.name)
    _write_template('index-debug.html.tpl', os.path.join(prefix, 'index-debug.html'), app_name=args.name)
    _write_template('Info.plist.tpl', os.path.join(prefix, 'Info.plist'), app_name=args.name)
    _write_template('Jakefile.tpl', os.path.join(prefix, 'Jakefile'), app_name=args.name)
    _write_template('main.j.tpl', os.path.join(prefix, 'main.j'), app_name=args.name)
    _write_template('AppController.j.tpl', os.path.join(prefix, 'AppController.j'), app_name=args.name)

    os.chdir(prefix)
    os.system('capp gen -fl .')

def _write_code_folder(prefix, class_prefix, name):
    """
    """
    os.makedirs(os.path.join(prefix, name))
    open(os.path.join(prefix, name, '%s%s.j' % (class_prefix, name)), 'a').close()

def _write_template(template_name, destination_path, **kwargs):
    """
    """
    with open(os.path.join('templates', template_name), 'r') as file:
        template = jinja2.Template(file.read(), *kwargs)

        with open(destination_path, 'w') as file:
            file.write(template.render(kwargs))

def main(argv=sys.argv):
    '''
    '''
    parser = argparse.ArgumentParser(description='Creates a new NUKit project')

    parser.add_argument('-n', '--name',
                        dest='name',
                        metavar='project name',
                        help='todo',
                        required=True,
                        type=str)

    parser.add_argument('-o', '--output',
                        dest='output',
                        metavar='path',
                        help='todo',
                        required=True,
                        type=str)

    parser.add_argument('-p', '--classprefix',
                        dest='class_prefix',
                        metavar='class prefix',
                        help='todo',
                        default='NU',
                        type=str)

    args = parser.parse_args()

    _init_structure(os.path.join(args.output, args.name), args)

if __name__ == '__main__':
    main()