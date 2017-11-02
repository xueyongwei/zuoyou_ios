#import <UIKit/UIKit.h>
#import "GPUImage.h"

@interface SimpleVideoFileFilterViewController : UIViewController
{
    GPUImageMovie *movieFile;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageMovieWriter *movieWriter;
    NSTimer * timer;
}
@property (nonatomic,strong)NSURL *videoURL;
@property (retain, nonatomic) IBOutlet UILabel *progressLabel;
- (IBAction)updatePixelWidth:(id)sender;

@end
