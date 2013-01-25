//
//  SDPRecentUploadsController.h
//  SourceDrop
//
//  Created by Michael Hohl on 22.04.12.
//  Copyright (c) 2012 Michael Hohl. All rights reserved.
//

///
/// Controller used to handle the recent uploads of SourceDrop.
///
@interface SDPRecentUploadsController : NSObject<NSMenuDelegate>
{
  @private
    NSMutableArray *_recentUploads;
}

/// contains the max number of recent uploads
@property (assign, nonatomic) NSUInteger maxRecentUploads;

/// array containing the most recent uploads
@property (strong, readonly) NSArray *recentUploads;

/// notes a new recent upload URL.
- (void)noteNewRecentUpload:(NSURL *)uploadURL title:(NSString *)title;

@end
