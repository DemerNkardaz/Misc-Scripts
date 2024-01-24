You need following JSON-table structure for correct work of Folders creatin script, which uses JSON-structure:
{
  "root": [
    {
      "name": "Folder",
      "childs": [
        {
          "name": "Folder",
          "childs": [
          ]
        }
      ]
    }
  ]
}
