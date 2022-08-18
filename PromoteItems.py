import sys
from arcgis import gis
import clone_items
import data_safeguard

def promote(sourceURL, sourceAdmin, sourcePassword, destURL, destAdmin, destPassword, with_backup=False):
    source = gis.GIS(sourceURL, sourceAdmin, sourcePassword)
    target = gis.GIS(destURL, destAdmin, destPassword)

    # Erase the current objects
    targetUser = target.users.search('username:*dev*')[0]
    existingItems = targetUser.items(folder="CAS")
    for eItem in existingItems:
        if with_backup:
		
            data_safeguard.backup_feature_service(target, eItem)
        eItem.delete()

    # Create the list of items to clone
    items = source.content.search('title:cleaning')

    item_ids = []
    for item in items:
        item_ids.append(item.id)
       
    # Define clone options
    clone_items.COPY_DATA = False
    clone_items.SEARCH_ORG_FOR_EXISTING_ITEMS = True
    clone_items.USE_DEFAULT_BASEMAP = False
    clone_items.ADD_GPS_METADATA_FIELDS = False
    clone_items.ITEM_EXTENT = None
    clone_items.SPATIAL_REFERENCE = None

    # Clone the items
    created_items = []

    for item_id in item_ids:
        # Get the item
        item = source.content.get(item_id)
        print('Cloning {0}'.format(item['title']))
            
        # Specify the name of the folder to clone the items to. If a folder by the name doesn't already exist a new folder will be created.
        folder_name = "CAS"

        # Clone the item to the target portal. The function will return all the new items that were created during the cloning. 
        created_items += clone_items.clone(target, item, folder_name, created_items)
    
    # Share the item in the organization
    for created_item in created_items:
        if with_backup:
            data_safeguard.restore_feature_services(created_item)
        # created_item.reassign_to(targetUser.username)
        created_item.share(org=True)



if __name__== "__main__":
    promote(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4],sys.argv[5],sys.argv[6],sys.argv[7])