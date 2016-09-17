//
//  OpenGLView.swift
//  basic-opengl-swift
//
//  Created by Steven Watson on 9/17/16.
//  Copyright © 2016 Steven Watson. All rights reserved.
//

import GLKit
import OpenGL

class OpenGLView: NSOpenGLView
{
    var displayLink: CVDisplayLink? = nil;
    
    
    override func prepareOpenGL()
    {
        /* Set up DisplayLink. */
        func displayLinkOutputCallback( displayLink: CVDisplayLink,
                                            _ inNow: UnsafePointer<CVTimeStamp>,
                                     _ inOutputTime: UnsafePointer<CVTimeStamp>,
                                          _ flagsIn: CVOptionFlags,
                                         _ flagsOut: UnsafeMutablePointer<CVOptionFlags>,
                               _ displayLinkContext: UnsafeMutableRawPointer? )
        -> CVReturn
        {
            /* Get an unsafe instance of self from displayLinkContext. */
            let unsafeSelf = Unmanaged<OpenGLView>.fromOpaque( displayLinkContext! ).takeUnretainedValue()
            
            unsafeSelf.draw(unsafeSelf.frame)
            return kCVReturnSuccess
        }
        
        CVDisplayLinkCreateWithActiveCGDisplays( &displayLink )
        CVDisplayLinkSetOutputCallback( displayLink!, displayLinkOutputCallback, Unmanaged.passUnretained(self).toOpaque() )
        CVDisplayLinkStart( displayLink! )
        
        /* BUG: When exiting a fullscreen view windowClosing() will be called. */
        NotificationCenter.default.addObserver( self, selector: #selector( OpenGLView.windowClosing ),
                                                          name: NSNotification.Name.NSWindowWillClose,
                                                        object: nil )
    }
    
    
    override func draw(_ dirtyRect: NSRect)
    {
        self.openGLContext!.makeCurrentContext()
        CGLLockContext( self.openGLContext!.cglContextObj! )
        
        
        glClearColor( Float(cos( CACurrentMediaTime() )),  /* Red */
                      Float(cos( CACurrentMediaTime() )),  /* Green */
                      Float(sin( CACurrentMediaTime() )),  /* Blue */
                                                     1.0 ) /* Alpha */
        glClear( GLbitfield(GL_COLOR_BUFFER_BIT) )
        
        
        CGLFlushDrawable( self.openGLContext!.cglContextObj! )
        CGLUnlockContext( self.openGLContext!.cglContextObj! )
    }
    
    
    func windowClosing()
    {
        CVDisplayLinkStop( displayLink! );
    }
}
