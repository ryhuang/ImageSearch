//
//  SearchViewController.m
//  ImageSearch
//
//  Created by Richard Huang on 11/17/13.
//  Copyright (c) 2013 Huang Corp. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()

@property (nonatomic, strong) NSDictionary *results;
@property (weak, nonatomic) IBOutlet UIImageView *returnedImage;

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Image Search";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - UISearchBar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [self.view endEditing:YES];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@", [searchBar.text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]]];
    
    //Make an asynchronous request for the data
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:url] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            NSLog(@"Error with query string");
        } else {
            NSError *localError = nil;
            NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&localError];
            
            if (localError != nil) {
                NSLog(@"Json error");
            }else{
                self.results = parsedObject;
                //get first image
                NSString *urlString = [[[[parsedObject objectForKey:@"responseData"] objectForKey:@"results"]objectAtIndex:0] objectForKey:@"url"];
                [self getImage:urlString];
            }
        }
    }];

    
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    return YES;
}


-(void) getImage:(NSString *)url
{
    [NSURLConnection sendAsynchronousRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if(error){
            NSLog(@"Error retrieving image");
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *img = [[UIImage alloc] initWithData:data ];
                //actually set the image here
                [self.returnedImage setImage:img];
            });
        }
    }];
}

@end
