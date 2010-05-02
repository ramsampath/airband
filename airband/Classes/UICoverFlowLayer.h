

@interface UICoverFlowLayer : NSObject // CALayer
{
    void *_private;
}

- (id)initWithFrame:(struct CGRect)fp8 numberOfCovers:(unsigned int)fp24 numberOfPlaceholders:(unsigned int)fp28;
- (unsigned int)numberOfCovers;
- (unsigned int)numberOfPlaceholders;
- (void)dealloc;
- (void)setDelegate:(id)fp8;
- (void)setPlaceholderImage:(void *)fp8 atPlaceholderIndex:(unsigned int)fp12;
- (void)setPlaceholderIndicesForCovers:(unsigned int *)fp8;
- (void)_prefetch:(unsigned int)fp8 atIndex:(unsigned int)fp12;
- (void)_requestBatch;
- (void)_requestImageAtIndex:(int)fp8 quality:(unsigned int)fp12;
- (void)_requestImageAtIndex:(int)fp8;
- (void)_notifySelectionDidChange;
- (void)transitionIn:(float)fp8;
- (void)transitionOut:(float)fp8;
- (void)transition:(unsigned int)fp8 withCoverFrame:(struct CGRect)fp12;
- (void)transitionIn:(float)fp8 fromFrame:(struct CGRect)fp12;
- (void)transitionOut:(float)fp8 toFrame:(struct CGRect)fp12;
- (void)setDisplayedOrientation:(int)fp8 animate:(BOOL)fp12;
- (void)setInfoLayer:(id)fp8;
- (void)setImage:(void *)fp8 atIndex:(unsigned int)fp12 type:(unsigned int)fp16;
- (void)setImage:(void *)fp8 atIndex:(unsigned int)fp12 type:(unsigned int)fp16 imageSubRect:(struct CGRect)fp20;
- (void)setImage:(void *)fp8 atIndex:(unsigned int)fp12;
- (unsigned int)indexOfSelectedCover;
- (unsigned int)_coverAtScreenPosition:(struct CGPoint)fp8;
- (void)_recycleLayer:(int)fp8 to:(int)fp12;
- (void)_setNewSelectedIndex:(int)fp8;
- (void)_updateTick;
- (void)displayTick;
- (void)dragFlow:(unsigned int)fp8 atPoint:(struct CGPoint)fp12;
- (void)selectCoverAtIndex:(unsigned int)fp8;
- (void)selectCoverAtOffset:(int)fp8;
- (unsigned int)coverIndexAtPosition:(float)fp8;
- (void)_setupFlippedCoverLayer:(id)fp8;
- (void)flipSelectedCover;
- (int)benchmarkTick;
- (void)benchmarkHeartbeatLongScrub;
- (void)benchmarkHeartbeatShortScrub;
- (void)benchmarkHeartbeatScrubAndWait;
- (void)benchmarkTightLoop;
- (void)benchmarkTightLoopScrub;
- (BOOL)benchmarkLoadScrub;
- (BOOL)benchmarkImageManager:(void *)fp8;
- (void)benchmarkSetEnv;
- (void)benchmarkMode:(int)fp8;
- (void)benchmarkTickMode:(int)fp8;
- (void)benchmarkImageMode:(int)fp8;
- (void)benchmarkPerformanceLog:(BOOL)fp8;
- (void)benchmarkTightLoopTime:(unsigned int)fp8;
- (void)benchmarkLongScrubSpeed:(float)fp8;
- (void)benchmarkSkipImageLoad:(BOOL)fp8;

@end

