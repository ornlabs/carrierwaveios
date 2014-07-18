#import "ViewController.h"

#define BASE_URL @"http://localhost:3000/"

@interface ViewController ()

- (void)createRating:(UIImage *)chosenImage;
- (void)uploadRatingImage:(UIImage *)chosenImage withRatingId:(NSString *)ratingId;
- (void)downloadAndDisplayImage:(NSString *)imageURL;

@end

@implementation ViewController

- (IBAction)takePictureAction:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    if(![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else
    {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.takePictureButton.enabled = NO;
    [self.loadingActivityIndicatorView startAnimating];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [self createRating:info[UIImagePickerControllerEditedImage]];
    }];
}

- (void)createRating:(UIImage *)chosenImage
{
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@ratings", BASE_URL]]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"POST"];
    
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:@{@"rating":@{@"description":@"Test description"}} options:kNilOptions error:&error];
    [request setHTTPBody:postData];
    
    NSURLSessionTask *createRatingTask = [session dataTaskWithRequest:request
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        
                                                        if(((NSHTTPURLResponse *)response).statusCode == 201)
                                                        {
                                                            NSError *jsonError;
                                                            NSDictionary *ratingResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                                                            
                                                            [self uploadRatingImage:chosenImage withRatingId:ratingResponse[@"id"]];
                                                        }
                                                        else
                                                        {
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                [[[UIAlertView alloc] initWithTitle:@"Error creating"
                                                                                            message:@"Could not create new rating"
                                                                                           delegate:nil
                                                                                  cancelButtonTitle:@"OK"
                                                                                  otherButtonTitles:nil] show];
                                                                
                                                                [self.loadingActivityIndicatorView stopAnimating];
                                                                self.takePictureButton.enabled = YES;
                                                            });
                                                        }

                                                    }];
    [createRatingTask resume];
}

- (void)uploadRatingImage:(UIImage *)chosenImage withRatingId:(NSString *)ratingId
{
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@ratings/%@/image", BASE_URL, ratingId]]];
    [request addValue:@"image/jpeg" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"PUT"];
    
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:request
                                                               fromData:UIImageJPEGRepresentation(chosenImage, 0.8)
                                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                          
                                                          if(((NSHTTPURLResponse *)response).statusCode == 202)
                                                          {
                                                              NSError *jsonError;
                                                              NSDictionary *imageResponse = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                                                              
                                                              [self downloadAndDisplayImage:[NSString stringWithFormat:@"%@/%@", BASE_URL, imageResponse[@"image"][@"url"]]];
                                                          }
                                                          else
                                                          {
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  [[[UIAlertView alloc] initWithTitle:@"Error uploading"
                                                                                              message:@"Could not upload image for rating"
                                                                                             delegate:nil
                                                                                    cancelButtonTitle:@"OK"
                                                                                    otherButtonTitles:nil] show];
                                                                  
                                                                  [self.loadingActivityIndicatorView stopAnimating];
                                                                  self.takePictureButton.enabled = YES;
                                                              });
                                                          }
                                                      }];
    [uploadTask resume];
}

- (void)downloadAndDisplayImage:(NSString *)imageURL
{
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionTask *imageDownloadTask = [session dataTaskWithURL:[NSURL URLWithString:imageURL]
                                                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

                                                     UIImage *image = [UIImage imageWithData:data];
                                                     
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         self.resultImageView.image = image;
                                                         [self.loadingActivityIndicatorView stopAnimating];
                                                         self.takePictureButton.enabled = YES;
                                                     });
                                                     
                                                 }];
    [imageDownloadTask resume];
}

@end
