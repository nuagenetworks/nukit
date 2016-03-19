/*
 * NUFileDropController.j
 *
 * Copyright (C) 2010 Antoine Mercadal <antoine.mercadal@inframonde.eu>
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

@import <Foundation/Foundation.j>
@import <AppKit/CPImage.j>
@import <AppKit/CPView.j>

@import "NUSkin.j"

@global FileReader


isWinSafari = false;
if (typeof(navigator) != "undefined")
{
    isWinSafari = (navigator.userAgent.indexOf("Windows") > 0 && navigator.userAgent.indexOf("AppleWebKit") > 0) ? true : false ;
}

var DCFileDropableTargets = [];


/*! @ignore
*/
@implementation NUFileDropController : CPObject
{
    BOOL        _enabled                @accessors(getter=isEnabled);
    CPArray     _validFileTypes         @accessors(property=validFileTypes);
    CPView      _view                   @accessors(property=view);

    CPString    _oldBoxShadowCSS;
    DOMElement  _fileInput;
    id          _delegate;
}

- (id)initWithView:(CPView)theView dropDelegate:(id)theDropDelegate
{
    if (self = [super init])
    {
        _view     = theView;
        _delegate = theDropDelegate;

        [self setEnabled:YES];
        [self setFileDropState:NO];

        window.document.body.addEventListener("dragover", function(anEvent)
        {
            if (![DCFileDropableTargets containsObject:anEvent.toElement] || ![self validateDraggedFiles:anEvent.dataTransfer.files])
            {
                anEvent.dataTransfer.dropEffect = "none";
                anEvent.preventDefault();
                return NO;
            }
            return YES;
        }, NO);

        _view._DOMElement.addEventListener("dragenter", function(anEvent)
        {
            if (![self validateDraggedFiles:anEvent.dataTransfer.files])
                return NO;

            if (![self isEnabled])
                return NO;

            anEvent.dataTransfer.dropEffect = "copy";
            anEvent.stopPropagation();
            [self fileDraggingEntered:anEvent];
        }, NO);

        _fileInput                       = document.createElement("input");
        _fileInput.accept                = @"image/gif, image/jpeg, image/png, image/jpeg";
        _fileInput.type                  = "file";
        _fileInput.id                    = "filesUpload";
        _fileInput.style.position        = "absolute";
        _fileInput.style.top             = "0px";
        _fileInput.style.left            = "0px";
        _fileInput.style.backgroundColor = "#00FF00";
        _fileInput.style.opacity         = "0";

        _view._DOMElement.style.cursor = "pointer";
        // _view._DOMElement.style.transition = "0.1s";

        _view._DOMElement.addEventListener("click", function(anEvent)
        {
            if (![self isEnabled])
                return;

            _fileInput.click();
        }, NO);

        _view._DOMElement.addEventListener("mouseover", function(anEvent)
        {
            if (![self isEnabled])
                return;
            _oldBoxShadowCSS = _view._DOMElement.style.boxShadow || _view._DOMElement.style.WebkitBoxShadow || _view._DOMElement.style.MozBoxShadow;
            _view._DOMElement.style.boxShadow = @"0 0 0 3px " + [NUSkinColorBlue cssString];
            _view._DOMElement.style.WebkitBoxShadow = @"0 0 0 3px " + [NUSkinColorBlue cssString];
            _view._DOMElement.style.MozBoxShadow = @"0 0 0 3px " + [NUSkinColorBlue cssString];
        }, NO);

        _view._DOMElement.addEventListener("mouseout", function(anEvent)
        {
            _view._DOMElement.style.boxShadow = _oldBoxShadowCSS;
            _view._DOMElement.style.WebkitBoxShadow = _oldBoxShadowCSS;
            _view._DOMElement.style.MozBoxShadow = _oldBoxShadowCSS;
        }, NO);

        if (!isWinSafari)
        {
            // there seems to be a bug in the Windows version of Safari with multiple files, where all X number of files will be the same file.
            _fileInput.setAttribute("multiple",true);
        }

        _fileInput.addEventListener("change", function(anEvent) {
            [self fileDropped:anEvent];
        }, NO);

        _fileInput.addEventListener("dragleave", function(anEvent) {
            [self fileDraggingExited:anEvent];
        }, NO);

        [DCFileDropableTargets addObject:_fileInput];

        [self setFileElementVisible:NO];
    }

    return self;
}

- (BOOL)validateDraggedFiles:(FileList)files
{
    if (![_validFileTypes count])
        return YES;

    for (var i = 0; i < files.length; i++)
    {
        // we really can only check the filename :(
        var filename = files.item(i).name,
            type = [[filename pathExtension] lowercaseString];

        return [_validFileTypes containsObject:type];
    }

    return YES;
}

- (void)setFileDropState:(BOOL)visible
{
    if ([_delegate respondsToSelector:@selector(fileDropUploadController:setState:)])
        [_delegate fileDropUploadController:self setState:visible];
}

- (void)setFileElementVisible:(BOOL)yesNo
{
    // use just a file element
    if (yesNo)
    {
        _fileInput.style.width = "100%";
        _fileInput.style.height = "100%";
        _view._DOMElement.appendChild(_fileInput);
    }
    else
    {
        _fileInput.style.width = "0%";
        _fileInput.style.height = "0%";
        if (_fileInput.parentNode)
            _fileInput.parentNode.removeChild(_fileInput);
    }
}

- (void)fileDraggingEntered:(id)sender
{
    [self setFileDropState:YES];
    [self setFileElementVisible:YES];
}

- (void)fileDraggingExited:(id)sender
{
    [self setFileDropState:NO];
    [self setFileElementVisible:NO];
}

- (void)fileDropped:(id)sender
{
    [self setFileDropState:NO];
    [self setFileElementVisible:NO];

    var files = sender.target.files,
        reader = new FileReader();

    reader.onload = function(evt)
    {
        var data = [CPData dataWithBase64:evt.target.result.split(",")[1]];
        [_view setImage:[[CPImage alloc] initWithData:data]];

        if ([_delegate respondsToSelector:@selector(fileDropUploadController:didDropImage:)])
            [_delegate fileDropUploadController:self didDropImage:[_view image]];

    };

    reader.readAsDataURL(files[0]);

    _fileInput.value = nil;
}

- (void)setEnabled:(BOOL)shouldEnable
{
    _enabled = shouldEnable;

    _view._DOMElement.style.cursor = _enabled ? @"pointer" : @"";
}

@end
