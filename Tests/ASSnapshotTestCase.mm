//
//  ASSnapshotTestCase.mm
//  Texture
//
//  Copyright (c) Facebook, Inc. and its affiliates.  All rights reserved.
//  Changes after 4/13/2017 are: Copyright (c) Pinterest, Inc.  All rights reserved.
//  Licensed under Apache 2.0: http://www.apache.org/licenses/LICENSE-2.0
//

#import "ASSnapshotTestCase.h"
#import <AsyncDisplayKit/ASAvailability.h>
#import <AsyncDisplayKit/ASDisplayNode+Beta.h>
#import <AsyncDisplayKit/ASDisplayNodeExtras.h>
#import <AsyncDisplayKit/ASDisplayNode+Subclasses.h>

NSOrderedSet *ASSnapshotTestCaseDefaultSuffixes(void)
{
  NSMutableOrderedSet *suffixesSet = [[NSMutableOrderedSet alloc] init];
  // In some rare cases, slightly different rendering may occur on iOS 10 (text rasterization).
  // If the test folders find any image that exactly matches, they pass;
  // if an image is not present at all, or it fails, it moves on to check the others.
  // This means the order doesn't matter besides reducing logging / performance.
  if (AS_AT_LEAST_IOS10) {
    [suffixesSet addObject:@"_iOS_10"];
  }
  [suffixesSet addObject:@"_64"];
  return [suffixesSet copy];
}

@implementation ASSnapshotTestCase

+ (void)hackilySynchronouslyRecursivelyRenderNode:(ASDisplayNode *)node
{
  // Disable asynchronous display for rendering snapshots since things like UITraitCollection are thread-local
  // so changes to them (`-[UITraitCollection performAsCurrentTraitCollection]`) aren't preserved across threads.
  // Since the goal of this method is to just to ensure a node is rendered before snapshotting, this should be reasonable default for all callers.
#if AS_AT_LEAST_IOS13
  if (@available(iOS 13.0, *)) {
    ASTraitCollectionPropagateDown(node, ASPrimitiveTraitCollectionFromUITraitCollection(UITraitCollection.currentTraitCollection));
  }
#endif // #if AS_AT_LEAST_IOS13
  node.displaysAsynchronously = NO;
  ASDisplayNodePerformBlockOnEveryNode(nil, node, YES, ^(ASDisplayNode * _Nonnull node) {
    [node.layer setNeedsDisplay];
  });
  [node recursivelyEnsureDisplaySynchronously:YES];
}

@end
