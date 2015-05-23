//
//  ViewController.m
//  MapSample
//
//  Created by Pablo Parejo Camacho on 22/5/15.
//  Copyright (c) 2015 Pablo Parejo Camacho. All rights reserved.
//

#import "ViewController.h"

@import MapKit;
@import CoreLocation;

@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *latLabel;
@property (weak, nonatomic) IBOutlet UILabel *lonLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    
    self.mapView.mapType = MKMapTypeHybrid;
    self.mapView.showsUserLocation = YES;
    self.mapView.showsBuildings = YES;
    self.mapView.pitchEnabled = YES;
    
    self.mapView.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *location = [locations lastObject];
    self.latLabel.text = [NSString stringWithFormat:@"%.6f", location.coordinate.latitude];
    self.lonLabel.text = [NSString stringWithFormat:@"%.6f", location.coordinate.longitude];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error){
                       if (placemarks.count > 0) {
                           CLPlacemark *placemark = [placemarks firstObject];
                           self.addressLabel.text = [NSString stringWithFormat:@"%@, %@", [placemark thoroughfare], [placemark locality]];
                           MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                           annotation.coordinate = location.coordinate;
                           annotation.title = placemark.thoroughfare;
                           [self.mapView addAnnotation:annotation];
                       }
                       
    }];
    MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.05, 0.05));
    [self.mapView setRegion:region animated:YES];
}

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"%@", error);
}

-(void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    NSLog(@"Region changed: %.2f", mapView.region.span.latitudeDelta);
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView
           viewForAnnotation:(id<MKAnnotation>)annotation{
    MKPinAnnotationView *view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"ANNOTATION"];
    view.pinColor = MKPinAnnotationColorGreen;
    view.animatesDrop = YES;
    return view;
}

@end
