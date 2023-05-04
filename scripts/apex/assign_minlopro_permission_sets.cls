Id runningUserId = UserInfo.getUserId();
Map<Id, PermissionSet> permissionSetsByIds = new Map<Id, PermissionSet>(
        [SELECT Id, Name FROM PermissionSet WHERE IsCustom = TRUE AND Name LIKE 'Minlopro_%']
);
List<PermissionSetAssignment> psaItems = new List<PermissionSetAssignment>();
for (PermissionSet psItem : permissionSetsByIds.values()) {
    psaItems.add(
            new PermissionSetAssignment(
                PermissionSetId = psItem.Id,
                AssigneeId = runningUserId
            )
    );
}
if (!psaItems.isEmpty()) {
    Database.insert(psaItems, false);
}
System.debug(
        String.format(
                '\n\n Successfully assigned "Minlopro"-like permission sets to [{0}] user. \n',
                Lists.of(UserInfo.getName()))
);