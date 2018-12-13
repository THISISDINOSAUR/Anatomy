# Anatomy

A DSL  capable of specifying arbitrary skeletons with interrelationships, constraints, and bounded parameters. Designed to be used to create procedural creature generators.

This is the first step in a planned pipeline for THE DINOSAUR GENERATOR:  
Anatomy definition -> Racket server -> Web UI

## Potential future features

**Current priorities:**
Getting a first version of the full stack done, i.e:
- Server v1 
- Front end v1

This will require the following to be implemented first: 
- Cleaning up parameter setters
- Reading/parsing parameters


### Language level features

- Better output for parameters  
Currently printing parameters prints the raw hashmap. A more user friendly output could be provided.
It may well make sense to implement this by converting that hashmap into a custom parameters object, which would also be useful for the cleaning up of parameter setters.

- Cleaning up parameter setters  
Currently parameters setters are stored in the parameters hashmap, so are exposed to users. They should either be moved to a private data structure, or handled as part of a separate parameters object (see above).

- Reading/parsing parameters  
It is currently unclear what the expectation is for how a script might actually use an Anatomy file, i.e. how it should read the allowed parameter ranges so it can then choose values for them. Probably best to have a consistent interface, regardless of what name is given to the parameters definition in the anatomy file.

- Ability to reference point dimensions  
At the moment you can't reference a specific dimension of a point. I've never needed it, but it feels like an omission, and something that should be very simple to add.

- Rotate function  
Rotating bones could be useful, particularly for the root bone

- Syntax colouring  
Should be reasonably straightforward to implement, but without much benefit or pressing need.

- Better error messages  
Requires proper investigation into where they are currently lacking. Will be better to implement after using the language a bit.

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

~~- Assignment to a single bone point
It's possible to mutate a single point with compound operators, but it should also be possible to assign a value to a single point as well~~

- Standalone average function
For both points and values

- Appending points to bones
Or inserting at a specific index

- Distributing bones over a line
E.g. distributing vertebrae over the spine. This could lead to wanting other helper methods to e.g. scale them towards one end. Raises the question of what they should be connected to.

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

- Relative/absolute points/points pinned to specific bones  
Defining shapes that have points that are relative to different bones is essential for implementing soft tissue stuff. Exactly how they should be implemented though is another matter entirely. In theory they perhaps ought to be calculated after the entire skeleton has been calculated, but then this poses interesting questions about what will happen when someone tries to use the individual points as part of something else. 
Perhaps could have two types, deferred and none deferred, i.e. a non deferred point would give you the absolute position of a point on a bone at the time of defining the non deferred point, and any subsequent changes to that bone wouldn't be applied to that point. This would have the advantage that this point could then be used without issue in anyway. This would essentially require that any relative points be defined after the skeleton (which is a limitation that makes sense).  
A deferred point could be defined relative to a bone, and then no matter what happens to that bone, would keep its relative position to that bone. This could certainly be useful, although substantially more complicated to implement. Easiest way to implement would probably to mutate relative points at the same time as mutating the rest of the bone.  
Probably start with the nondeferred points, and then see where we go from there.

- Soft body  
Absolutely can't be done without relative points (see above). Should otherwise be simple to do a preliminary implementation, and is absolutely essential for actually rendering something.

- Muscles or other things to define mass  
Likely to be more useful once in 3D. Haven't thought much about how this might be done or what might be useful. An interesting thing to think about for the future, but currently no intentions to add.

- Other details (e.g. spines, spikes, thagomizers, horns)  
Definitely required, but currently little thoughts on how best to implement. Would probably require to distribute a certain number of something along a line, with different sizes and frequencies at different points (e.g. bigger spines in the middle of the body).  
At least horns should be easy.

- Reading in presets/definitions  
Essential feature, ability to define and import individual creature definitions (i.e. sets of specific parameter values e.g. a stegosaur)

- Phylogentic information  
Presets/creature definitions could contain additional phylogentic information (e.g. suborder, family, etc.). This could then be used to construct a procedurally generated phylogentic tree. This could then be used to infer other information about the generated creatures (e.g. their relationship to other creatures).
Not a priority, but should be relatively straight forward and cool

- Other meta information in presets  
By including other information about presets (e.g what they ate, where they lived, temporal range etc.), further information could be inferred about generated creatures. How to best structure this information is unclear at this time, and this is a far off goal. Definitely would be cool though. Probably best if individual types of info are added as desired (e.g. temporal range would be an easy one to start with).

- Preset inheritance  
Would be useful to define presets relative to other presets (e.g have a general Stegosauria, and then define Stegosauridae relative to that, etc.). Could have a concept of abstract presets, that are for inheriting from only, and don't represent real creatures.

- Preset parameter ranges  
At least when it comes to certain parameters (e.g. spine distribution, soft tissue stuff), it may make sense for an individual species to have a range for certain parameters, rather than a specific value (e.g. tail length can be between 1.2 and 1.4, rather than just 1.3). Exactly how this would interact with any ML for the parameter value generation is unclear.
May be worth implementing, and then ignoring it for most purposes (e.g. just taking the middle value).  
Slight complication: the far range of one parameter might not be compatible with the far range of another (e.g. longer neck and shorter tail). If I do implement this, I should definitely use with caution.

- Preset parameter sub specifications
Attempt to accomplish same as parameter ranges, but instead have the ability to define subsets of parameters on a preset (e.g. two different pairs of tail lengths and neck lengths).

- Clean up expander (and maybe parser)
The expander's gotten quite large and unorganised, and could do with some reorganisation.

### Ecosystem level features

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

- Server  
Top priority. A server that reads an anatomy, exposes the parameter information, takes in parameter values, and then uses those to regenerate the anatomy, and then outputs the new anatomy.

- Web UI  
Top priority after the server. A website that uses the server to display the generated creature, and provide an interface to edit the parameters.

- Racket interface  
It's potentially also worth considering a racket interface to make it easier to iterate on anatomy files. This will depend on how easy it is to set the server up in such a way that changes to the anatomy file will be immediately reflected in the web UI.

- Texturing  
Currently little thoughts on the best way to do texturing. May use some sort of masking system, with similar tools to the other details (e.g. spikes), for things like varying stripes.  
Currently not a goal, with no plans to implement much in the way of texturing.

- Animation  
Few thoughts on potential options, but really too early for anything concrete. More of a goal than texturing. May try some simple IK as an experiment. Unsure at what stage to handle this (i.e. language level, or later down the pipeline?). Requires many questions to be answered, like should it export meshes with rigs and skin weights, or should it bake animations?

### TODO on dinosaur.anatomy

- Dinosaur skeleton reference  
Use the large number of skeletal references I posses to identify where new parameters are required to be able to define all dinosaurs.  
Perhaps start by defining all high level dinosaurs (e.g. suborder) as presets, adding parameters until they are adequate, and then progressively drilling deeper down the phylogentic tree.

- Armoured dinosaurs  
The armoured dinosaurs are currently particularly lacking, so there should be particular focus on how to improve these as a reasonably high priority

- 'The fancy bits'  
Currently don't represent things like horns, spikes, spines etc. I consider this fairly superficial and not a priority, but worth bearing in mind.

- Skeleton detail  
Skeletal detail is currently quite low. This is deliberate, since scientifically accurate representations isn't currently the main goal. It is however interesting, and is definitely something I want to keep in the back of my mind. I may generally aim to gradually increase the detail, and potentially nurture this as either a separate project, or keep trying to work it into the main generation pipeline.

- Skull detail  
Skull detail currently nonexistent. Not a priority to change until successfully rending something, since I think we get away with it. However, once that's achieved, it should be a reasonably high priority.


### Potential tangential projects

- 'Homologous structures' implementation  
Reimplementation of the 'Homologous structures' infographic in anatomy. Would provide a good measure of how the language holds up and where it is lacking

- 'Wing types' implementation  
Same as above but for wing types.

- Beak generator   
Similar to above. Could be a nice self contained project that also has the potential to be part of a larger project. Due to the relative simplicity, could be a good test bed for forays into 3D.
