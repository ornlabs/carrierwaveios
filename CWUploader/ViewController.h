#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivityIndicatorView;
@property (weak, nonatomic) IBOutlet UIImageView *resultImageView;
@property (weak, nonatomic) IBOutlet UIButton *takePictureButton;

- (IBAction)takePictureAction:(id)sender;

@end

