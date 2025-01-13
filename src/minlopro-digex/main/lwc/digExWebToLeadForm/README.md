# Salesforce Web-To-Lead (W2L) Form

Below is a typical HTML representation of W2L form:

```
<!--  ----------------------------------------------------------------------  -->
<!--  NOTE: Please add the following <META> element to your page <HEAD>.      -->
<!--  If necessary, please modify the charset parameter to specify the        -->
<!--  character set of your HTML page.                                        -->
<!--  ----------------------------------------------------------------------  -->

<META HTTP-EQUIV="Content-type" CONTENT="text/html; charset=UTF-8">

<!--  ----------------------------------------------------------------------  -->
<!--  NOTE: Please add the following <FORM> element to your page.             -->
<!--  ----------------------------------------------------------------------  -->

<form action="https://test.salesforce.com/servlet/servlet.WebToLead?encoding=UTF-8&orgId=00DKM000000LRrY" method="POST">

    <input type=hidden name="oid" value="00DKM000000LRrY">
    <input type=hidden name="retURL" value="https://www.youtube.com/watch?v=sxoFEN9kz6c">

    <!--  ----------------------------------------------------------------------  -->
    <!--  NOTE: These fields are optional debugging elements. Please uncomment    -->
    <!--  these lines if you wish to test in debug mode.                          -->
    <!--  <input type="hidden" name="debug" value=1>                              -->
    <!--  <input type="hidden" name="debugEmail" value="test@gmail.com">      -->
    <!--  ----------------------------------------------------------------------  -->

    <label for="first_name">First Name</label>
    <input id="first_name" maxlength="40" name="first_name" size="20" type="text" /><br>

    <label for="last_name">Last Name</label>
    <input id="last_name" maxlength="80" name="last_name" size="20" type="text" /><br>

    <label for="email">Email</label>
    <input id="email" maxlength="80" name="email" size="20" type="text" /><br>

    <label for="company">Company</label>
    <input id="company" maxlength="40" name="company" size="20" type="text" /><br>

    <label for="some_custom_field">Some Custom Field</label>
    <input id="some_custom_field" maxlength="40" name="00N34000005KYzq" size="20" type="text" /><br>

    <input type="submit" name="submit">
</form>
```

## API

Salesforce W2L API is represented as a **public** endpoint in Salesforce organization. `POST` HTTP requests are expected to be sent to this endpoint.

There are rules to the HTTP request payload to follow:

1. the payload must contain Salesforce organization ID parameter (see `oid` form parameter)

-   this parameter is used to route the Lead to the right Salesforce organization
-   `oid` accepts either 15 or 18 digit Salesforce instance ID (both work, but the latter one is preferred)

2. form parameter names must correspond to valid custom/standard fields on **Lead** object in target Salesforce organization:

-   if the form contains a parameter that does not match Lead standard/custom field then the value of this parameter will be lost
-   the form parameters can be mapped by _Salesforce Field API Name_ and/or by its _Salesforce Field ID_:
    -   `<input name="SomeCustomField__c" ...` – is a valid approach to map form parameter by Salesforce field API name
    -   `<input name="00N34000005KYzq" ...` – is a valid approach to map form parameter by Salesforce field ID (i.e. `00N34000005KYzq` corresponds to `SomeCustomField__c` field ID in Salesforce)

**Salesforce Field IDs are preserved between Salesforce instances**. Therefore the same field IDs can be defined as form parameter names in counterpart environments (dev, test & prod envs).

To identify Salesforce Field ID use the SOQL query below (see `DurableId` column):

```
SELECT QualifiedApiName, DataType, DurableId, Description
FROM FieldDefinition
WHERE EntityDefinition.QualifiedApiName = 'Lead'
ORDER By QualifiedApiName ASC
```

Aforementioned query works with _Tooling API_ only.

## Mapping Standard Lead Fields

| **Lead Standard Field API Name** | **Form Parameter Name** | **Details**                      |
| -------------------------------- | ----------------------- | -------------------------------- |
| `FirstName`                      | `first_name`            | Lowercase, contains underscore   |
| `LastName`                       | `last_name`             | Lowercase, contains underscore   |
| `Email`                          | `email`                 | Lowercase                        |
| `Company`                        | `company`               | Lowercase                        |
| `Phone`                          | `phone`                 | Lowercase                        |
| `LeadSource`                     | `lead_source`           | Lowercase, contains underscore   |
| `Address`                        | `city`                  | Part of 'Address' compound field |
| `Address`                        | `street`                | Part of 'Address' compound field |
| `Address`                        | `state`                 | Part of 'Address' compound field |
| `Address`                        | `zip`                   | Part of 'Address' compound field |
| `Description`                    | `description`           | Lowercase                        |
