
  $( document ).ready(function() {
   
    //Back4app
    Parse.serverURL = "https://parseapi.back4app.com";
    Parse.initialize("45cgsAjYqwQQRctQTluoUpVvKsHqrjCmvh72UGBx");     
    Parse.javaScriptKey = "Xkg4PiKyxFJPPA2GncRCxdzaOmblseMbr8050vGb";    

    var currentUser = Parse.User.current();
    if (!currentUser) {
        window.location = "../index.html";
    }

    var selectedItem = [];   
    var selected = -1; 
    var schoolsLenght = 0;
    var schoolName;

     var schoolObjs = [];

    loadschools();

    var parseFileThumbanil, parseFileIso;     

    var schoolIdArray = [];
    var _sId, _schoolId_for_grade;   

    function loadschools()
    {
  
        querySchools = new Parse.Query("Schools");      
        querySchools.find({
            success: function (schools) {

                if (schools) {                

                  schoolObjs = schools;
                  schoolsLenght = schools.length;
                  var dataJson = [];

                  for (var i = 0; i < schoolsLenght; ++i) 
                  {
                      item = {};
                      item["id"] = i+1;
                      var objectId = schools[i].id;
                      dataJson.objectId = objectId;   
                      schoolIdArray.push(objectId);                   
                      item["objectId"] = objectId; 
                      item["short"] = schools[i].get("short");                                      
                      if (schools[i].get("thumbnail") != undefined){                
                        var thumbnail = schools[i].get("thumbnail");
                        item["thumbnail"] = thumbnail._url;
                      } else {
                        item["thumbnail"] = "https://dummyimage.com/60x60/286090/ffffff.png&text=NA";
                      }                      
                      var name = schools[i].get("name");
                      item["name"] = name;                      
                      dataJson.push(item);
                  }                          

                  var rowIds = [];
                  var grid = $("#gridSchool").bootgrid({                  
                      templates: {
                          header: "<div id=\"{{ctx.id}}\" class=\"{{css.header}}\"><div class=\"row\"><div class=\"col-sm-12 actionBar\"><div class=\"btn\"><div id=\"loader_school\" class=\"loader\"/></div><button type=\"button\" id=\"new_school\" class=\"btn btn-primary\"><span class=\"glyphicon glyphicon-plus-sign\">&nbsp;</span> New school </button> <p class=\"{{css.search}}\"></p><p class=\"{{css.actions}}\"></p></div></div></div>"       
                      }, 
                      caseSensitive: true,
                      selection: true,
                      multiSelect: true,
                      keepSelection: true,
                      rowSelect: true,                
                      formatters: {              
                        "thumbnail": function (column, row) {
                            return "<img src=\"" + row.thumbnail + "\" height=\"30\" width=\"85\"/>";
                        },                        
                        "commands": function(column, row) {
                            return "<button type=\"button\" class=\"btn btn-xs btn-default command-delete\" data-row-id=\"" + row.id + "\"><span class=\"glyphicon glyphicon-trash\"></span></button>&nbsp;" + 
                                   "<button type=\"button\" class=\"btn btn-xs btn-default command-edit\" data-row-id=\"" + row.id + "\"><span class=\"glyphicon glyphicon-edit\"></span></button>&nbsp;";                                    
                        },
                        "grades": function(column, row) {
                            //                                                        
                            return "<button type=\"button\ data-school-id=\"" + row.objectId + "\" class=\"btn btn-xs btn-default command-grades\" data-row-id=\"" + row.id + "\">Grades</button>&nbsp;";                                       
                        }                    
                      }  

                  }).on("selected.rs.jquery.bootgrid", function(e, rows) {                     

                       if ( selectedItem.length > 0) {                       
                           $("#gridSchool").bootgrid("deselect", [parseInt(selected)]);                                              
                       }

                      let countSelected=0;
                      let rowIds = [];
                      let schoolId;
                      let short; 
                      for (var i = 0; i < rows.length; i++)
                      {                      
                          rowIds.push(rows[i].id); 
                          schoolId = rows[i].objectId; 
                          short = rows[i].short; 

                      }              

                      selected = rowIds.join(",");
                      selectedItem.push(selected);   

                      //Categories
                      var event = new CustomEvent("LoadCategories", { detail: [schoolId,short] });
                      document.dispatchEvent(event);
                      
                      //Gifts
                      var event = new CustomEvent("LoadGifts", { detail: [schoolId,short] });
                      document.dispatchEvent(event); 
                      
                      //Welcomes
                      var event = new CustomEvent("LoadWelcomes", { detail: [schoolId,short] });
                      document.dispatchEvent(event);                     

                  }).on("deselected.rs.jquery.bootgrid", function(e, rows)
                  {
                      var rowIds = [];
                      for (var i = 0; i < rows.length; i++)
                      {
                          rowIds.push(rows[i].id);                      
                      }
                      
                  }).on("loaded.rs.jquery.bootgrid", function() {  

                        $("#loader_school").hide();                

                        $( "#btn_edit_school" ).unbind("click").click(function() {
                            saveSchool();
                        });  

                        $( "#btn_add_school" ).unbind("click").click(function() {
                           addGrade();
                        }); 

                        $( "#save_grades_container" ).unbind("click").click(function() {
                           saveGrades();
                        });                                          

                        $( "#new_school" ).unbind("click").click(function() {

                          $("#school_title").text("New school"); 

                          $('#edit_model_school').modal('show');                 

                          $("#input_thumb_school").unbind("change").change(function() {
                            loadThumbImage(this);
                          });

                          $("#input_iso_school").unbind("change").change(function() {
                            loadIsoImage(this);
                          });              

                        }); 

                      /* Executes after data is loaded and rendered */
                      grid.find(".command-edit").on("click", function(e) {

                          //alert("You pressed edit on row: " + $(this).data("row-id"));
                          var ele =$(this).parent();
                          var g_id = $(this).parent().siblings(':first').html();
                          var g_name = $(this).parent().siblings(':nth-of-type(2)').html();

                          console.log(g_id);
                          console.log(g_name);

                          //console.log(grid.data());//
                          $('#edit_model_school').modal('show');

                          if ($(this).data("row-id") >0) {

                            var f = ele.siblings(':first').html();                        
                            var a1 = ele.siblings(':nth-of-type(1)').html();
                            var a2 = ele.siblings(':nth-of-type(2)').html();
                            var a3 = ele.siblings(':nth-of-type(3)');
                            var a4 = ele.siblings(':nth-of-type(4)').html();
                            var a5 = ele.siblings(':nth-of-type(5)').html();
                            var a6 = ele.siblings(':nth-of-type(6)').html();
                            var a7 = ele.siblings(':nth-of-type(7)').html();

                            // collect the data
                            //$('#edit_id').val(ele.siblings(':first').html());                                                
                            $("#edit_thumbnail").append(a4);                            
                            $('#edit_name').val(a6);
                            $('#edit_backimage').append(a7); 

                            $("#school_title").text("Edit school - " + a6);                       

                          } else {
                             alert('Now row selected! First select row, then click edit button');
                          }

                      }).end().find(".command-grades").on("click", function(e) {

                          $('#edit_modal_grade').modal('show');                                                                 

                          var row  = $(this).attr('data-row-id');                                                   

                          _sId = row-1;

                          _schoolId_for_grade = schoolIdArray[_sId]; //$(this).attr('data-school-id');   

                      }).end().find(".command-delete").on("click", function(e) {


                      }).end().find(".command-fanpage").on("click", function(e) {                    


                      });
                  });                  

                } else {
                    console.log("Nothing found, please try again");
                }
                
                grid.bootgrid("clear");
                grid.bootgrid("append", dataJson);

            },
            error: function (error) {
                console.log("Error: " + error.code + " " + error.message);
            }
        });
    }
         
    
    function loadThumbImage(input) {
        if (input.files && input.files[0]) {         
          var reader = new FileReader();
          reader.onload = function (e) {
            $('#img_thumbnail_school').attr('src', e.target.result);
          }
          reader.readAsDataURL(input.files[0]);
          var desc = $("#edit_name").val();
          desc = desc.replace(/[^a-zA-Z ]/g, "");
          desc = desc.replace(" ", "");
          if (hasWhiteSpace(desc))
            desc = desc.replace(" ", "");
          var thunbname = "t_" + desc.toLowerCase() + ".png";
          parseFileThumbanil = new Parse.File(thunbname, input.files[0], "image/png");                   
        }
    }    

    function loadIsoImage(input) {
        if (input.files && input.files[0]) {         
          var reader = new FileReader();
          reader.onload = function (e) {
            $('#img_iso_school').attr('src', e.target.result);
          }
          reader.readAsDataURL(input.files[0]);
          var desc = $("#edit_name").val();
          desc = desc.replace(/[^a-zA-Z ]/g, "");
          desc = desc.replace(" ", "");
          if (hasWhiteSpace(desc))
            desc = desc.replace(" ", "");
          var thunbname = "i_" + desc.toLowerCase() + ".png";
          parseFileIso = new Parse.File(thunbname, input.files[0], "image/png");                   
        }
    }   

    function hasWhiteSpace(s) {
      return s.indexOf(' ') >= 0;
    }

    function saveSchool() {          

          var Schools = Parse.Object.extend("Schools");         
          var school = new Schools();    
          school.set("thumbnail", parseFileThumbanil);
          school.set("iso", parseFileIso);
          school.set("name", $("#edit_name").val());   
          var short =  $("#edit_short").val();          
          school.set("short", short);           

          school.save(null, {
              success: function (schoolNew) {                  
          
                  Parse.Cloud.run("AddRoleByName", { "name": short}).then(function(schoolRolePF) {

                      var currentUser = Parse.User.current();

                      let name = schoolRolePF.get("name");

                      Parse.Cloud.run("AddUserToRole", { "userId": currentUser.id, "role": name});

                      console.log('school created successful with name: ' + schoolNew.get("pageName"));                                   

                      checkKnownCategoryExistByName(short, function(categoriesPF) {
                          
                            saveCategoriesForTarget(categoriesPF, short);                                            

                      });       
                      
                      createSchoolS3Folder();

                  });

                  

              },
              error: function (response, error) {
                  console.log('Error: ' + error.message);
              }

          });
          
      }      

      function checkKnownCategoryExistByName(short, callback) {

          var trending = "TRENDING";
          var personal = "PERSONAL";

          let queryCategories = new Parse.Query("Categories");  
          queryCategories.containedIn("name", [trending, personal]);                    
          queryCategories.find({
            success: function (categoriesPF) {

                let categoriesArray = [];

                if (categoriesPF.length>0)
                {
                    let count = categoriesPF.length;                  

                    for (let i=0; i<count; i++) {                       

                        let categoryPF = categoriesPF[i];

                        let name = categoryPF.get("name");

                        if ( (name == trending) || (name == personal) ) {

                            categoriesArray.push(categoryPF);
                        }
                    }
                }

                if (categoriesArray.length > 0) {

                    callback(categoriesArray);

                } else {

                    // Create New
                    createCategories(short);
                }

            },
            error: function (error) {
                console.log("Error: " + error.code + " " + error.message);
            }

          });
      } 
      
      function saveCategoriesForTarget(categoriesPF, short) {

            let cat0 = categoriesPF[0];          

            cat0.add("target", short); 
            cat0.save();

            let cat1 = categoriesPF[1];

            cat1.add("target", short); 
            cat1.save();

            loadschools();
            clearField();           

            $('#edit_model_school').modal('hide');

    }

      function createCategories(short) {                

          var queryImages = new Parse.Query("Images");  
          queryImages.ascending("createdAt");    
          queryImages.find({
            success: function (images) {

                    var personal, personalBackground, trending, trendingBackground;

                    for (var i=0;i<images.length; i++) {
                        var image = images[i];
                        var name = image.get("name");
                        if (name=="personal") {
                            personal = image.get("image");                        
                        } else if (name=="trending") {
                            trending = image.get("image");                                            
                        } else if (name=="personal_background") {
                            personalBackground = image.get("image");                        
                        } else if (name=="trending_background") {
                            trendingBackground = image.get("image");
                        }
                    } 

                    var categoriesArrayCreated = [];              

                    var Category = Parse.Object.extend("Categories"); 
                    var categoryPersonal = new Category();    
                    categoryPersonal.set("thumbnail", personal);
                    categoryPersonal.set("backImage", personalBackground);
                    categoryPersonal.set("name", "PERSONAL");
                    categoryPersonal.set("order", 1);                                      
                    categoryPersonal.set("description", "Personal pages for each registeres kid to customize");                                          
                  
                    categoryPersonal.save(null, { 
                        success: function (catPerPF) {              	                          	                  
                  
                            categoriesArrayCreated.push(catPerPF);

                            var categoryTrending = new Category();    

                            categoryTrending.set("thumbnail", trending);
                            categoryTrending.set("backImage", trendingBackground);                            
                            categoryTrending.set("name", "TRENDING");  
                            categoryTrending.set("order", 0);                                      
                            categoryTrending.set("description", "Most viewed and liked fanpages, trendings in general");                                       

                            categoryTrending.save(null, { 
                                success: function (catTrendPF) {                          

                                    categoriesArrayCreated.push(catTrendPF);  
                                    
                                    saveCategoriesForTarget(categoriesArrayCreated, short);

                                },
                                error: function (error) {
                                    console.log('Error! ' + error.message);
                                }
                            }); 

                        },
                        error: function (error) {
                            console.log('Error! ' + error.message);
                        }
                    }); 

                },
                error: function (error) {
                    console.log("Error: " + error.code + " " + error.message);
                }
           });  

      }

      function addGrade() {          

          var gradeName = $('#edit_grade_name').val();
          var gradeNumber = $('#edit_grade_number').val();

          $(".grade_addition").append('<li>' + gradeNumber + " - " + gradeName + '</li>');  

          $('#edit_grade_number').val("");
          $('#edit_grade_name').val("");
      }

      function saveGrades(){

          var Levels = Parse.Object.extend("Level");  

          var optionTexts = [];
          $("#grade_list li").each(function() { optionTexts.push($(this).text()) });

          var lsize = optionTexts.length;
          var count = 1;

          for (var i=0; i<lsize; i++) { 

            var values = optionTexts[i];

            var res = values.split("-");

            var level = new Levels();
            level.set("grade", parseInt(res[0]));            
            level.set("schoolId",  _schoolId_for_grade);
            level.set("description", res[1].replace(/\s/g,''));           

            level.save(null, {
              success: function (albumStored) {
                    
                    var schoolObj = schoolObjs[_sId];
                    
                    var alRelation = schoolObj.relation("levels");
                    alRelation.add(albumStored);

                    schoolObj.save(null, {
                      success: function (album) {

                            if (lsize == count) {
                              $('#edit_modal_grade').modal('hide');                
                              clearField(); 
                            }
                            count++;
                      },
                      error: function (response, error) {
                          console.log('Error: ' + error.message);
                      }

                    });
              },
              error: function (response, error) {
                  console.log('Error: ' + error.message);
              }

            });
          } 
      }

      function clearField(){
        $("#edit_model_school").find("input[type=text], textarea").val("");
        $("#edit_model_school").find("input[type=file], textarea").val("");      
        $('#img_thumbnail_school').attr('src', "https://upload.wikimedia.org/wikipedia/commons/c/ca/1x1.png");             
        $('#img_iso_school').attr('src', "https://upload.wikimedia.org/wikipedia/commons/c/ca/1x1.png");                     
        $("#img_back").attr('src', "https://upload.wikimedia.org/wikipedia/commons/c/ca/1x1.png");             
      }


      function createSchoolS3Folder() {

        let short =  $("#edit_short").val();          

        Parse.Cloud.run("createS3Folder", { folder: s3folder }).then(function(result) {    

            console.log("__________________________");                         
            console.log(JSON.stringify(result));       
           
        }, function(error) {

            console.log("error :" +errort);
            // error

            $('#error_message').html("<p>" + errort + "</p>");

        });  
      }

    window.otherSchools = [];  

    window.loadOtherSchools = function(schoolId)
    {  
        let queryOtherSchools = new Parse.Query("Schools");  
        queryOtherSchools.notEqualTo("objectId", schoolId);          
        queryOtherSchools.find({
            success: function (schools) {

                if (schools.length>0)
                {
                    var count = schools.length;                  

                    for (var i=0; i<count; i++) {                       

                        var school = schools[i];

                        let shortName = school.get("short");
                        let schoolName = school.get("name");

                        var other = { short: shortName, name: schoolName };

                        otherSchools.push(other);                  

                    }
                }
            },
            error: function (error) {
                console.log("Error: " + error.code + " " + error.message);
            }
        });
    }

    window.getCheckedRole = function(formname) {        

        var aclArray = [];
        var countChecks = 0;
        var numberOfChecked = $('input[type="checkbox"]').is(":checked").length;

        if ( numberOfChecked > 0 ) {

          $('#' + formname + ' input[type="checkbox"]').each(function() {
              
              if ($(this).is(":checked")) {
              
                  let short = $(this).val();
                  
                  var queryRole = new Parse.Query(Parse.Role);    
                  queryRole.equalTo('name', roleName);    

                  queryRole.first({useMasterKey:true}).then(function(rolePF) {

                      aclArray.push(rolePF); 

                      if (countChecks == (numberOfChecked-1)) {
                        return aclArray;
                      }

                      countChecks++;

                  });

              }

          });

        } else {

          return aclArray;
        }
        
     }


     window.loadRole = function(roleName) { 

        var queryRole = new Parse.Query(Parse.Role);    
        queryRole.equalTo('name', roleName);    

        queryRole.first({useMasterKey:true}).then(function(rolePF) {           

           return rolePF;
           
        });

    }

  });

 



