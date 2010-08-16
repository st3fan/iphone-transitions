/*
 * (C) Copyright 2008, Stefan Arentz, Arentz Consulting.
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <QuartzCore/QuartzCore.h>
#import "UIViewControllerTransitions.h"

static NSMutableSet* sViewControllerParents = nil;

static UIViewController* FindParentViewController(UIViewController* viewController)
{
	for (NSDictionary* dictionary in sViewControllerParents) {
		if ([dictionary objectForKey: @"ViewController"] == viewController) {
			return [dictionary objectForKey: @"ParentViewController"];
		}
	}
	return nil;
}

static void RemoveViewController(UIViewController* viewController)
{
	for (NSDictionary* dictionary in sViewControllerParents) {
		if ([dictionary objectForKey: @"ViewController"] == viewController) {
			[sViewControllerParents removeObject: dictionary];
			return;
		}
	}
}

@implementation UIViewController (Transitions)

- (void) presentModalViewController: (UIViewController*) viewController withTransitionStyle: (UIViewControllerTransitionInStyle) transitionStyle;
{
	if (sViewControllerParents == nil) {
		sViewControllerParents = [NSMutableSet new];
	}

	if (FindParentViewController(viewController) != nil) {
		NSLog(@"UIViewController#presentModalViewController:withTransitionStyle: already showing viewController");
		return;
	}
	
	[sViewControllerParents addObject:
		[NSDictionary dictionaryWithObjectsAndKeys: self, @"ParentViewController", viewController, @"ViewController", nil]];

	[viewController retain];

	[self.view removeFromSuperview];
	
	viewController.view.frame = self.view.frame;

	// If the parent of this modal view controller is a UITabBarController then we need to adjust the origin
	// of the view so that we are not under the status bar. (If not hidden)

	if ([self isKindOfClass: [UITabBarController class]]) {
		if ([[UIApplication sharedApplication] isStatusBarHidden] == NO) {
			CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
			CGRect frame = viewController.view.frame;
			frame.origin.y = statusBarFrame.size.height;
			viewController.view.frame = frame;
		}
	}

	switch (transitionStyle)
	{
		case UIViewControllerTransitionStylePushInFromRight:
		{
			UIWindow* window = [[UIApplication sharedApplication] keyWindow];
			[window addSubview: viewController.view];

			NSString *direction = kCATransitionFromLeft;

			switch (self.interfaceOrientation) {
				case UIInterfaceOrientationPortrait:
					direction = kCATransitionFromRight;
					break;
				case UIInterfaceOrientationPortraitUpsideDown:
					direction = kCATransitionFromLeft;
					break;        
				case UIInterfaceOrientationLandscapeLeft:
					direction = kCATransitionFromBottom;
					break;
				case UIInterfaceOrientationLandscapeRight:
					direction = kCATransitionFromTop;
					break;
			}

			CATransition *animation = [CATransition animation];
			[animation setDuration: 0.25];
			[animation setType: kCATransitionPush];
			[animation setSubtype: direction];
			[animation setTimingFunction: [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];

			[[window layer] addAnimation: animation forKey: @"presentViewController"];

			break;
		}

		case UIViewControllerTransitionStylePushInFromLeft:
		{
			UIWindow* window = [[UIApplication sharedApplication] keyWindow];
			[window addSubview: viewController.view];

			NSString *direction = kCATransitionFromLeft;

			switch (self.interfaceOrientation) {
				case UIInterfaceOrientationPortrait:
					direction = kCATransitionFromLeft;
					break;
				case UIInterfaceOrientationPortraitUpsideDown:
					direction = kCATransitionFromRight;
					break;        
				case UIInterfaceOrientationLandscapeLeft:
					direction = kCATransitionFromTop;
					break;
				case UIInterfaceOrientationLandscapeRight:
					direction = kCATransitionFromBottom;
					break;
			}

			CATransition *animation = [CATransition animation];
			[animation setDuration: 0.25];
			[animation setType: kCATransitionPush];
			[animation setSubtype: direction];
			[animation setTimingFunction: [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];

			[[window layer] addAnimation: animation forKey: @"presentViewController"];

			break;
		}
	}
}

- (void) dismissAnimationDidStop: (NSString*) animationID finished: (NSNumber*) finished context: (void*) context
{
	[self.view removeFromSuperview];
	self.view = nil;
	
	[self release];
}

- (void) dismissModalViewControllerWithTransitionStyle: (UIViewControllerTransitionOutStyle) transitionOutStyle;
{
	UIViewController* parentViewController = FindParentViewController(self);
	if (parentViewController == nil) {
		NSLog(@"UIViewController#dismissModalViewControllerWithTransitionStyle: cannot find parent view controller");
		return;
	}

	switch (transitionOutStyle)
	{
		case UIViewControllerTransitionStylePushOutToRight:
		{
			[self.view removeFromSuperview];

			UIWindow* window = [[UIApplication sharedApplication] keyWindow];
			[window addSubview: parentViewController.view];

			// TODO [parentView addSubview:contentView];

			NSString* direction = kCATransitionFromLeft;

			switch (self.interfaceOrientation) {
				case UIInterfaceOrientationPortrait:
					direction = kCATransitionFromLeft;
					break;
				case UIInterfaceOrientationPortraitUpsideDown:
					direction = kCATransitionFromRight;
					break;      
				case UIInterfaceOrientationLandscapeLeft:
					direction = kCATransitionFromTop;
					break;
				case UIInterfaceOrientationLandscapeRight:
					direction = kCATransitionFromBottom;
					break;
			}

			CATransition *animation = [CATransition animation];
			[animation setDuration: 0.25];
			[animation setType: kCATransitionPush];
			[animation setSubtype: direction];
			[animation setTimingFunction: [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];

			[[window layer] addAnimation: animation forKey: @"dismissViewController"];
			
			break;
		}

		case UIViewControllerTransitionStylePushOutToLeft:
		{
			[self.view removeFromSuperview];

			UIWindow* window = [[UIApplication sharedApplication] keyWindow];
			[window addSubview: parentViewController.view];

			// TODO [parentView addSubview:contentView];

			NSString* direction = kCATransitionFromLeft;

			switch (self.interfaceOrientation) {
				case UIInterfaceOrientationPortrait:
					direction = kCATransitionFromRight;
					break;
				case UIInterfaceOrientationPortraitUpsideDown:
					direction = kCATransitionFromLeft;
					break;      
				case UIInterfaceOrientationLandscapeLeft:
					direction = kCATransitionFromBottom;
					break;
				case UIInterfaceOrientationLandscapeRight:
					direction = kCATransitionFromTop;
					break;
			}

			CATransition *animation = [CATransition animation];
			[animation setDuration: 0.25];
			[animation setType: kCATransitionPush];
			[animation setSubtype: direction];
			[animation setTimingFunction: [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];

			[[window layer] addAnimation: animation forKey: @"dismissViewController"];
			
			break;
		}
	}
	
	RemoveViewController(self);
}

@end
