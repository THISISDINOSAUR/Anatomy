# Anatomy

A DSL  capable of specifying parameterised arbitrary skeletons. Designed to be used to create procedural creature generators. For example, a single bird skeleton could be defined, with parameters that modify various aspects of it, so that, depending on the parameter values, different bird species can be represented.

This is the first two steps in the pipeline for THE DINOSAUR GENERATOR, containing both the language, and the server that serves the generated results (as well as associated information, such as information on the allowed parameter values, and the defined presets):  
Anatomy definition -> Racket server -> Web UI  

And now also with inbuilt rendering:  
Anatomy definition -> Racket UI  
  

Example dinosaur, with animated changing parameter values:
![Example dinosaur](http://thecreativeperiod.com/elle/images/theDinosaurGeneratorSmall.gif)  


## Current TODO

### Anatomy Language

- Fix points printing wrong points (what values does it print?)

- Fix angle when rendering partial skeletons

- Check what happens when scaling a bone with no parent  
This case isn't explicitly handled, so I'm not sure what will happen

- Allow empty params definition (or no params definition)  

- Relative/absolute points/points pinned to specific bones  
Defining shapes that have points that are relative to different bones is essential for implementing soft tissue stuff. Exactly how they should be implemented though is another matter entirely. In theory they perhaps ought to be calculated after the entire skeleton has been calculated, but then this poses interesting questions about what will happen when someone tries to use the individual points as part of something else. 
Perhaps could have two types, deferred and none deferred, i.e. a non deferred point would give you the absolute position of a point on a bone at the time of defining the non deferred point, and any subsequent changes to that bone wouldn't be applied to that point. This would have the advantage that this point could then be used without issue in anyway. This would essentially require that any relative points be defined after the skeleton (which is a limitation that makes sense).  
A deferred point could be defined relative to a bone, and then no matter what happens to that bone, would keep its relative position to that bone. This could certainly be useful, although substantially more complicated to implement. Easiest way to implement would probably to mutate relative points at the same time as mutating the rest of the bone.  
Probably start with the nondeferred points, and then see where we go from there.

- Soft body  
Absolutely can't be done without relative points (see above). Should otherwise be simple to do a preliminary implementation, and is absolutely essential for actually rendering something.

- Preset inheritance  
Would be useful to define presets relative to other presets (e.g have a general Stegosauria, and then define Stegosauridae relative to that, etc.). Could have a concept of abstract presets, that are for inheriting from only, and don't represent real creatures.

### dinosaur.anatomy

- Protodinosaur  
Refactor dinosaur layout so that default position is as close to a protodinosaur as possible. Then progressively define presets further and further down the phylogentic tree.

## Potential future features

### Anatomy Language


- Add addressable connections  
At the moment, a connection only exists as a property on the parent bone, rather than as a standard racket variable itself (e.g. attempts to access `illium~scapula` will yield nothing).

- Ability to reference point dimensions  
At the moment you can't reference a specific dimension of a point. I've never needed it, but it feels like an omission, and something that should be very simple to add.

- Rotate function  
Rotating bones could be useful, particularly for the root bone

- Syntax colouring  
Should be reasonably straightforward to implement, but without much benefit or pressing need.

- Better error messages  
Requires proper investigation into where they are currently lacking. Will be better to implement after using the language a bit.

- Add REPL support  
Add ability to use anatomy in the REPL. Think might be easy so is worth doing.

- Conditionals  
Almost certainly required sooner or later, particularly when it comes to adding different parameter types. Some minor implementation questions remain, but will likely be resolved in the course of implementing them.  
Should be relatively straightforward to implement, but quite involved, and with a lot fundamental decisions about how the language works required.

- Functions  
Almost certainly useful, but currently no current need for them, as any functions I might want to add it typically makes sense to add as built in functions. Before I can do this, I need to know how I will handle scope, return types, and function parameters. Will likely consider implementing when the need arises.

- Multiline comments  
Should be straightforward, no reason not to implement

- Maths with short form connection point indexing  
E.g.   
`illium~pubis = average(0,last) + [20, 30]...`   
is not currently allowed, whereas:  
`illium~pubis = illium.average(0,last) + [20, 30]...`  
is allowed.   
To implement this would be fairly difficult for the benefit it would provide, and it would be mostly for the sake of completion. It would however have the benefit of conceptually simplifying both the parser and expander for connection points, making the short form `average()` syntax implementation truly syntactic sugar, as opposed to existing as a separate concept. Would be implemented by traversing the two `a-connection-point` in a connection definition, finding any instance of contextless `a-point-index`es or `a-point-function`s, and replacing them with the bone version, using the bones from the left side of the connection definition.

- Compound operators on variables  
It's currently possible to use compound operators (e.g. `+=`) when performing operations on bone ranges, but not on variables

- Standalone average function  
For both points and values. This could be difficult as long as the short form average function exists in connection points

- Appending points to bones  
Or inserting at a specific index

- Distributing bones over a line  
E.g. distributing vertebrae over the spine. This could lead to wanting other helper methods to e.g. scale them towards one end. Raises the question of what they should be connected to.

- Modifier groups  
Ability to group points, so can perform transformations on non contiguous points (e.g. points 2-4, 7-12)

- Selection shapes  
Ability to group points, or perform transformations by using bounding shapes (e.g. group all points that fall within this bounding box). Very useful, but probably quite difficult to implement generically, although should be straight forward for just rectangles. Requires modifier groups first to be particularly useful

- Other parameter types (e.g. integer, bool)  
At the very least, booleans seem like an essential. However, this will complicate the entire stack, as the front end and the server will also need to know about this. Given that neither the front end or the server exist yet, will implement when required, probably when a first version of the entire stack is actually done, complete with some sort of front end.

- Toggling between 2d and 3d  
At the moment, points can be specified in 2d, but everything is automatically converted to 3d. This could be needlessly confusing for applications that are strictly 2d, as well as polluting the output. Could perhaps at least have a setting on whether to expose the third dimension to the user (although this could invite further confusion when accessing things as racket variables). 
Making the whole thing work actually using two dimensions would require too much unnecessary work, so won't be considered.

- Allow importing of racket functions  
Would really add to the extensibility of the language, but I currently have no idea what I'd use this for or what it would look like.

- Importing points/models/other anatomy files  
A potentially very useful feature, particularly for complex structures, and could be essential in paving the way for 3D. Could be built on top of ability to import racket functions. At least for 2d, I think importing anatomy files would be the most useful. For 3d, importing something like object files will be essential.

- 3D  
Very complicated, with no plans to implement until 2D dinosaurs are achieved.
Big questions about how to represent shapes in 3D. It seems unlikely that 3d bone shapes could be usually described by hand. This being said, given that the mail goal isn't skeletal detail, assembling structures out of helper functions (e.g. cuboids, trapezoids, spheroids) may be sufficient for most purposes. Importing files would be essential for greater detail.  
Coming up with a good way to define shapes in 3D by hand could still be very useful at least for simpler things.  
Perhaps think about more complex helper functions, with specific bones/structures in mind (e.g. helper function to make connected successive circles of points with different properties, that e.g. could be used to define a tail)


- Muscles or other things to define mass  
Likely to be more useful once in 3D. Haven't thought much about how this might be done or what might be useful. An interesting thing to think about for the future, but currently no intentions to add.

- Other details (e.g. spines, spikes, thagomizers, horns)  
Definitely required, but currently little thoughts on how best to implement. Would probably require to distribute a certain number of something along a line, with different sizes and frequencies at different points (e.g. bigger spines in the middle of the body).  
At least horns should be easy.

- Phylogentic information  
Presets/creature definitions could contain additional phylogentic information (e.g. suborder, family, etc.). This could then be used to construct a procedurally generated phylogentic tree. This could then be used to infer other information about the generated creatures (e.g. their relationship to other creatures).
Not a priority, but should be relatively straight forward and cool

- Other meta information in presets  
By including other information about presets (e.g what they ate, where they lived, temporal range etc.), further information could be inferred about generated creatures. How to best structure this information is unclear at this time, and this is a far off goal. Definitely would be cool though. Probably best if individual types of info are added as desired (e.g. temporal range would be an easy one to start with).

- Preset parameter ranges  
At least when it comes to certain parameters (e.g. spine distribution, soft tissue stuff), it may make sense for an individual species to have a range for certain parameters, rather than a specific value (e.g. tail length can be between 1.2 and 1.4, rather than just 1.3). Exactly how this would interact with any ML for the parameter value generation is unclear.
May be worth implementing, and then ignoring it for most purposes (e.g. just taking the middle value).  
Slight complication: the far range of one parameter might not be compatible with the far range of another (e.g. longer neck and shorter tail). If I do implement this, I should definitely use with caution.

- Preset parameter sub specifications  
Attempt to accomplish same as parameter ranges, but instead have the ability to define subsets of parameters on a preset (e.g. two different pairs of tail lengths and neck lengths).

- Mute output when importing to regular racket scripts  
Should be relatively easy to do

- Bone groups  
It could be useful to have separate shapes that can be treated as a single bone (e.g. when multiple bones make up a single joint). What this should look like is unclear.

### Racket UI  

- Make debug drawing dynamically sized  
At the moment, all debug elements are a fixed size, so depending on the scale of the thing being rendered, they may be far too small or far too large

- Add ability to select bones  
With display to show the position of the cursor relative to the selected bone

- Highlight on mouse over  
To reduce visual clutter, only show bone labels on mouse over (or when bone is selected?)

- Draw paths relative to bone

- Dragging points/bones/connection points?
Might not actually be too hard to implement, so may be worth it (just doing points is probably the most useful and the least complicated to implement)

### Server
  
A server that reads an anatomy, exposes the parameter information, takes in parameter values, and then uses those to regenerate the anatomy, and then outputs the new anatomy.


- Serve preset based on name  
At the moment presets are served by the front end giving the correct parameter values. It should be possible to request a preset by using only the name. Low priority, given that the front end handles this fine


### Web UI

A website that uses the server to display the generated creature, and provide an interface to edit the parameters.

- Request timeout  
Due to request smoothing, if a request takes a long time, it will block all other requests. There should be some kind of timeout on this.

- Request throttling  
Limit request so a reasonable rate to avoid overloading the server 

- Refactor rendering to be more generic  
Currently uses a hard coded 'initial position'

### Ecosystem

- Parameter range analysis  
Once sufficient presets are defined, writing a tool to analyze the used parameter values could be useful to cut down the anatomy definition. E.g. removing ranges of parameters that are unused, or if a parameter doesn't vary much to remove it entirely. Could potentially do even more complicated things, such as looking for covariant parameters, and using this information to simplify them into a single parameter.
Also would be cool to show information like the parameter ranges within a suborder.

- Parameter value generation  
I.e. the actual procedural creature generation.
Once sufficient presets are defined, these can be used to create a parameter value generator. Different techniques could be tried for this, some sort of ML will probably be the first attempt.  
Further exploration required to see if this can be done well without negative data (i.e. unfeasible creatures).

- Meta data inference  
If the presets have meta data (e.g. temporal range), this could be used to infer the same information about generated creatures.

- Creature data collector  
Write a tool to go through generated creatures en mass and save and mark them as either feasible or unfeasible, as a way of collecting data for the parameter value generation training. Should only write this tool if needed.

- Phylogentic tree  
If the presets have phylogentic information, then a phylogentic tree could be procedurally generated. This would be cool. It could be done without the presets having phylogentic information, although would obviously have less structure.

- Name generation  
Similarly to the phylogentic tree, names could be generated based on the the creatures position in the phylogentic tree.

- Other procedural diagrams and graphics  
For example, a size comparison chart

- Identifying defining characteristics  
What sets one species apart from the others? Or one family apart from another? Could create a tool that tells you.  
Not a goal, but could be fun.

- Creature labeling  
By labeling presets (e.g. 'cute', 'vicious'), could procedurally generate creatures with certain characteristics.  
Not a goal, but could be fun.

- Texturing  
Currently little thoughts on the best way to do texturing. May use some sort of masking system, with similar tools to the other details (e.g. spikes), for things like varying stripes.  
Currently not a goal, with no plans to implement much in the way of texturing.

- Animation  
Few thoughts on potential options, but really too early for anything concrete. More of a goal than texturing. May try some simple IK as an experiment. Unsure at what stage to handle this (i.e. language level, or later down the pipeline?). Requires many questions to be answered, like should it export meshes with rigs and skin weights, or should it bake animations?

### dinosaur.anatomy

- Dinosaur skeleton reference  
Use the large number of skeletal references I posses to identify where new parameters are required to be able to define all dinosaurs.  
Perhaps start by defining all high level dinosaurs (e.g. suborder) as presets, adding parameters until they are adequate, and then progressively drilling deeper down the phylogentic tree.

- Armoured dinosaurs  
The armoured dinosaurs are currently particularly lacking, so there should be particular focus on how to improve these as a reasonably high priority

- 'The fancy bits'  
Currently don't represent things like horns, spikes, spines etc. I consider this fairly superficial and not a priority, but worth bearing in mind.

- Skeleton detail  
Skeletal detail is currently quite low. This is deliberate, since scientifically accurate representations isn't currently the main goal. It is however interesting, and is definitely something I want to keep in the back of my mind. I may generally aim to gradually increase the detail, and potentially nurture this as either a separate project, or keep trying to work it into the main generation pipeline.  
Do wonder if I should prioritise this more since people find it way more impressive and it will be much more satisfying.

- Skull detail  
Skull detail currently nonexistent. Not a priority to change until successfully rending something, since I think we get away with it. However, once that's achieved, it should be a reasonably high priority.


### Potential tangential projects

- 'Homologous structures' implementation  
Reimplementation of the 'Homologous structures' infographic in anatomy. Would provide a good measure of how the language holds up and where it is lacking

- 'Wing types' implementation  
Same as above but for wing types.

- Beak generator   
Similar to above. Could be a nice self contained project that also has the potential to be part of a larger project. Due to the relative simplicity, could be a good test bed for forays into 3D.

- Bird feet or footprint generator
Similar to above. The nice appeal of footprints is it would be even easier, but would still tell you a lot about the bird. Would make a neat twitter bot. what would be especially cool is if I made a feet generator, and then used that to make a footprint generator.


  

## Done

### Anatomy Language

- Fix scaling  
Section scaling (and probably bone scaling) currently has an issue, where it appears the parent connection point isn't scaled with the rest of the bone.

- Fix arm  
Scaling the arm currently has an issue, needs investigation.  
On closer inspection, these seems to have something to do with duplicates

- Better output for parameters  
Currently printing parameters prints the raw hashmap. A more user friendly output could be provided.
It may well make sense to implement this by converting that hashmap into a custom parameters object, which would also be useful for the cleaning up of parameter setters.

- Cleaning up parameter setters  
Currently parameters setters are stored in the parameters hashmap, so are exposed to users. They should either be moved to a private data structure, or handled as part of a separate parameters object (see above).

- Reading/parsing parameters  
It is currently unclear what the expectation is for how a script might actually use an Anatomy file, i.e. how it should read the allowed parameter ranges so it can then choose values for them. Probably best to have a consistent interface, regardless of what name is given to the parameters definition in the anatomy file.

- Connections should have a consistent order  
Connections are currently stored in a hash map, so when returned don't have a consistent order. The could just be an array, and the connection object could contain the child bone (Which would make a number of other things easier as well (such as the json generating code))

- Assignment to a single bone point  
It's possible to mutate a single point with compound operators, but it should also be possible to assign a value to a single point as well

- Clean up expander  
The expander's gotten quite large and unorganised, and could do with some reorganisation.

- Reading in presets/definitions  
Essential feature, ability to define and import individual creature definitions (i.e. sets of specific parameter values e.g. a stegosaur)

- Parameters are out of order  

### Server

- URL parameters currently case insensitive  
This is because in racket `request-bindings` is case insensitive. Need to find an alternative for this.

- Server should serve available parameters  
This should include the allowed ranges and default value

- Parameter checks  
Should check the parameters actually exist, and check the allowed ranges, and handle appropriately

- Handle when no parameters specified  
Should  return dinosaur with default parameters. Also, need to reset parameters when regardless, to handle when only certain parameters are specified.

- Serve presets  

- Collect presets automatically    
At the moment, each preset has to be added to the list of presets served manually.

### Web UI

- Dinosaur fetching and drawing

- Fetching of parameters and constructing parameter sliders  
Includes then fetching the dinosaur with these parameters

- Request smoothing  
Currently requests a dinosaur on every input, leading to far to many server requests, and potential race conditions. Should at least implement a system where no requests are made whilst a request is pending

- Fix Z fighting  
All bones are currently rendered at the same z position, leading to z fighting.

- Print parameters button  
Reimplement print parameters button

- Preset buttons  
Fetching presets, constructing buttons for them, and then fetching the dinosaur with the correct parameters. Requires presets to be implemented on the server and at the language level.

- Update parameter sliders when setting a preset


