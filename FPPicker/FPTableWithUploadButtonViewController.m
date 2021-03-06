//
//  FPTableWithUploadButtonViewController.m
//  FPPicker
//
//  Created by Brett van Zuiden on 12/3/13.
//  Copyright (c) 2013 Filepicker.io (Couldtop Inc.). All rights reserved.
//

#import "FPTableWithUploadButtonViewController.h"

@interface FPTableWithUploadButtonViewController ()

@property UIButton *uploadButton;
@property UIView *uploadButtonContainer;

@end

@implementation FPTableWithUploadButtonViewController

static const CGFloat UPLOAD_BUTTON_CONTAINER_HEIGHT = 45.f;

// For displaying the uploading text, number of files
static UIColor *HAPPY_COLOR;

// For displaying an invalid number of files
static UIColor *ANGRY_COLOR;

+ (void)initialize
{
    //#4cd964
    HAPPY_COLOR = [UIColor colorWithRed:0.298f green:0.851f blue:0.392f alpha:1.f];
    //ff3b30
    ANGRY_COLOR = [UIColor colorWithRed:1.f green:0.231 blue:0.088 alpha:1.f];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                  style:UITableViewStylePlain];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.view addSubview:self.tableView];

    // Do any additional setup after loading the view.

    if (self.selectMultiple)
    {
        // Adding a button on the bottom that allows you to finish your upload

        CGRect bounds = self.view.bounds;

        // Pinned to the bottom

        self.uploadButtonContainer = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                              bounds.size.height - UPLOAD_BUTTON_CONTAINER_HEIGHT,
                                                                              bounds.size.width,
                                                                              UPLOAD_BUTTON_CONTAINER_HEIGHT)];
        self.uploadButtonContainer.hidden = YES;

        self.uploadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];

        self.uploadButton.frame = CGRectMake(0,
                                             0,
                                             bounds.size.width,
                                             UPLOAD_BUTTON_CONTAINER_HEIGHT);

        //[self.uploadButton setTintColor:[UIColor greenColor]];
        [self.uploadButtonContainer addSubview:self.uploadButton];
        [self.view addSubview:self.uploadButtonContainer];

        [self.uploadButton addTarget:self
                              action:@selector(uploadButtonTapped:)
                    forControlEvents:UIControlEventTouchUpInside];


        [self.uploadButton setTintColor:HAPPY_COLOR];

        //#F7F7F7
        UIColor *uploadButtonBackgroundColor = [UIColor colorWithHue:0
                                                          saturation:0
                                                          brightness:.97f
                                                               alpha:0.98f];

        [self.uploadButtonContainer setBackgroundColor:uploadButtonBackgroundColor];
        self.uploadButtonContainer.opaque = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    //Pinned to the bottom
    CGRect bounds = self.view.bounds;

    self.uploadButtonContainer.frame = CGRectMake(0,
                                                  bounds.size.height - UPLOAD_BUTTON_CONTAINER_HEIGHT,
                                                  bounds.size.width,
                                                  UPLOAD_BUTTON_CONTAINER_HEIGHT);

    self.uploadButton.frame = CGRectMake(0,
                                         0,
                                         bounds.size.width,
                                         UPLOAD_BUTTON_CONTAINER_HEIGHT);

    self.tableView.frame = bounds;

    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUploadButton:(NSInteger)count
{
    if (count == 0)
    {
        if (self.uploadButtonContainer.hidden)
        {
            // No-op
        }
        else
        {
            // Hide the upload button - slide out from bottom

            CGRect bounds = self.view.bounds;

            [UIView animateWithDuration:0.2f animations: ^{
                self.uploadButtonContainer.frame = CGRectMake(0,
                                                              CGRectGetHeight(bounds),
                                                              CGRectGetWidth(bounds),
                                                              UPLOAD_BUTTON_CONTAINER_HEIGHT);
                // Put the tableView back

                CGRect newFrame = self.tableView.frame;
                newFrame.size.height += UPLOAD_BUTTON_CONTAINER_HEIGHT;

                self.tableView.frame = newFrame;
            } completion: ^(BOOL finished) {
                if (finished)
                {
                    self.uploadButtonContainer.hidden = YES;
                }
            }];
        }
    }
    else
    {
        if (self.uploadButtonContainer.hidden)
        {
            // Show thyself - slide up from bottom
            // Ensure we're on top of all our various children

            [self.view addSubview:self.uploadButtonContainer];

            CGRect bounds = self.view.bounds;

            self.uploadButtonContainer.frame = CGRectMake(0,
                                                          CGRectGetHeight(bounds),
                                                          CGRectGetWidth(bounds),
                                                          UPLOAD_BUTTON_CONTAINER_HEIGHT);

            self.uploadButtonContainer.hidden = NO;

            [UIView animateWithDuration:0.2f animations: ^{
                // Shrink the tableView so we don't have overlap

                CGRect newFrame = self.tableView.frame;
                newFrame.size.height -= UPLOAD_BUTTON_CONTAINER_HEIGHT;

                self.tableView.frame = newFrame;

                self.uploadButtonContainer.frame = CGRectMake(0,
                                                              CGRectGetHeight(bounds) - UPLOAD_BUTTON_CONTAINER_HEIGHT,
                                                              CGRectGetWidth(bounds),
                                                              UPLOAD_BUTTON_CONTAINER_HEIGHT);
            }];
        }

        if (count > self.maxFiles && self.maxFiles != 0)
        {
            NSString* title;

            [self.uploadButton setEnabled:NO];

            if (self.maxFiles == 1)
            {
                title = @"Maximum 1 file";
            }
            else
            {
                title = [NSString stringWithFormat:@"Maximum %ld files", (long)self.maxFiles];
            }

            [self.uploadButton setTitle:title
                               forState:UIControlStateDisabled];

            [self.uploadButton setTitleColor:ANGRY_COLOR
                                    forState:UIControlStateDisabled];
        }
        else
        {
            NSString* title;

            [self.uploadButton setEnabled:YES];

            if (count == 1)
            {
                title = @"Upload 1 file";
            }
            else
            {
                title = [NSString stringWithFormat:@"Upload %ld files", (long)count];
            }

            [self.uploadButton setTitle:title
                               forState:UIControlStateNormal];
        }
    }
}

- (void)uploadButtonTapped:(id)sender
{
    [self.uploadButton setEnabled:NO];

    [self.uploadButton setTitleColor:HAPPY_COLOR
                            forState:UIControlStateDisabled];

    [self.uploadButton setTitle:@"Uploading files"
                       forState:UIControlStateDisabled];
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSAssert(NO, @"This method must be implemented by subclasses.");

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"This method must be implemented by subclasses.");

    return nil;
}

@end
