# Introduction

## STAQ-DIC 
Current DIC post-processing methods can lead to errors in analyzing the deformation fields of complex geometries, near edges of samples, or objects with discontinuities. Therefore, an appropriate subset size and step size which are defined to create a grid mesh across the ROI are of significance for getting better spatial resolution on those areas near the edges. However, the delicate balance needed for optimal results is difficult to achieve manually.

To address these limitations, we have developed a novel, automatic approach called the SpatioTemporally Adaptive Quadtree Mesh DIC method (STAQ-DIC). This method resolves deformation fields around complex geometries and discontinuities more accurately than conventional DIC post-processing algorithms by utilizing a spatially adaptive quadtree mesh generated from binary mask files to adjust the mesh resolution in areas of complex geometries or discontinuities.

With a binary mask file as an input to define the region of interest in each image, STAQ-DIC uses a recursive error-estimating algorithm to adjust the spatial resolution of the subset mesh near areas of complex geometry or discontinuities, while leaving solid regions or areas with simple geometry with a lower spatial resolution. By selectively and automatically adjusting the resolution of the subset mesh, computational costs are saved while still yielding accurate results.With low computational costs and quick processing time, STAQ-DIC is an accurate and efficient method for resolving deformation fields in DIC images. Typically, each DIC image’s deformations can be resolved within seconds. For details about STAQ-DIC, please refer to our previous paper\cite{STAQ-DIC}.

To ensure better performance in dealing with complex geometric boundaries, an accurate and smooth mask file for segments is needed.
In addition, large deformations posed another challenge to our adaptive DIC method. Potential large deformations during measurements may make correlation difficult. To solve this issue, the incremental-mode DIC is often used to guarantee the difference between two images is not too large\cite{...}. The incremental-mode DIC involves the update of reference images, which leads to the binary mask files needing to be updated simultaneously. If the number of images to be processed is large, lots of mask files need to be pre-created, which can take up a lot of time. Therefore, the key issue is how to generate accurate binary mask files quickly and automatically.

## Binary Mask File Generation with SAM
Recently, Meta's Fundamental AI research (FAIR) developed Segment Anything, a promptable image segmentation tool that generates object masks for any desired object within an image. 

Naturally, for use in conjunction with STAQ-DIC, the Segment Anything Model (SAM) has been adapted for use to segment the speckled DIC regions of DIC images. With an object mask overlaid on the DIC image, color thresholding methods can be used to extract binary mask files from the SAM output, and used as an input to STAQ-DIC for ROI definition over an entire DIC image sequence.

![Intro](https://github.com/Jeffrey-Leu/SAM-for-Binary-Mask-File-Generation/assets/98000977/38b8413c-c123-45c6-b1d4-960dff4e95c8)

# Setup

# Example

![fig_bubble](https://github.com/Jeffrey-Leu/SAM-for-Binary-Mask-File-Generation/assets/98000977/18d6cd68-6183-4ad2-8f68-4b038e4efe7b)


# Contact
Feel free to contact me at jleu@utexas.edu

# STAQ-DIC Citation/Resources
https://github.com/jyang526843/STAQ-DIC

https://doi.org/10.1007/s11340-022-00872-4

# Segment Anything Citation/Resources
https://segment-anything.com/

https://github.com/facebookresearch/segment-anything

https://doi.org/10.48550/arXiv.2304.02643


