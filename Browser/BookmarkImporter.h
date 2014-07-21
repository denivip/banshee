//
//  BookmarkImporter.h
//
//  Created by Alexandru Catighera on 10/11/12.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <libxml/xpath.h>

@interface BookmarkImporter : NSObject {
    NSManagedObjectContext *managedObjectContext;
    NSManagedObject *rootFolder;
    xmlNodeSetPtr allNodes;
}

- (void)loadBookmarksFromUrl:(NSURL *) url;
- (void) loadBookmarksFromNodes:(NSArray *)nodes inFolder:(NSManagedObject *)parentFolder scanDL:(BOOL)scanDL;
- (void) loadBookmarksFromChildrenNodes:(xmlNodePtr)children inFolder:(NSManagedObject *)parentFolder scanDL:(BOOL)scanDL;
- (void) loadBookmarksFromAllNodesinFolder:(NSManagedObject *)parentFolder scanDL:(BOOL)scanDL;

- (BOOL) save:(NSError **) err;

@property(nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, strong) NSManagedObject *rootFolder;
@property(nonatomic, assign) xmlNodeSetPtr allNodes;


@end
