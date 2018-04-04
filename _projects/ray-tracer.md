---
title: Ray Tracer Renderer in C++
subtitle: By Christopher Lemelin and Elijah Kliot
repo: https://github.com/ekliot/Global-Illumination-Ray-Tracer
---

This project aims to build a 3D renderer using ray tracing in C++, for the CSCI 711 Global Illumination class at RIT.

This is a semester-long project with the goal of reproducing the following image:

![Ray Tracing Goal]({{ "/assets/media/images/ray-tracer/ray-tracer_goal.jpg" | absolute_url }})

The project consists of seven basic checkpoints (the first was simply determining relative object values):

<div style="border-bottom: 1px solid white; padding-bottom: 1em;" class="tabs" data-tabs>
  <ul>
    <li><a href="">Check 2</a></li>
    <li><a href="">Check 3</a></li>
    <li><a href="">Check 4</a></li>
    <li><a href="">Check 5</a></li>
    <li><a href="">Check 6</a></li>
    <li><a href="">Check 7</a></li>
  </ul>
  <section>
    <h3>Ray-Tracing Framework</h3>

    <div id="FrameworkCarousel" class="carousel" data-carousel-mode="slide">
      <ol>
        <li></li>
        <li></li>
      </ol>

      <figure class="carousel-active">
        <a href="/assets/media/images/ray-tracer/chkpt2_img1.png"
           class="frame_group" data-modal-group=".frame_group"
           data-modal-title="Recreating a basic scene">
          <img src="/assets/media/images/ray-tracer/chkpt2_img1.png">
        </a>
        <figcaption>
          <h4>Recreating a basic scene</h4>
        </figcaption>
      </figure>

      <figure>
        <a href="/assets/media/images/ray-tracer/chkpt2_img2.png"
           class="frame_group" data-modal-group=".frame_group"
           data-modal-title="With alternate camera angle">
          <img src="/assets/media/images/ray-tracer/chkpt2_img2.png">
        </a>
        <figcaption>
          <h4>With alternate camera angle</h4>
        </figcaption>
      </figure>
      <button><</button>
      <button class="forward"></button>
    </div>
  </section>

  <section>
    <h3>Phong Illumination</h3>

    <div id="PhongCarousel" class="carousel" data-carousel-mode="slide">
      <ol>
        <li></li>
        <li></li>
        <li></li>
        <li></li>
      </ol>

      <figure class="carousel-active">
        <a href="/assets/media/images/ray-tracer/chkpt3_img1.png"
           class="phong_group" data-modal-group=".phong_group"
           data-modal-title="Basic Phong Illumination">
          <img src="/assets/media/images/ray-tracer/chkpt3_img1.png">
        </a>
        <figcaption>
          <h4>Basic Phong Illumination</h4>
        </figcaption>
      </figure>

      <figure>
        <a href="/assets/media/images/ray-tracer/chkpt3_img2.png"
           class="phong_group" data-modal-group=".phong_group"
           data-modal-title="With supersampling x4">
          <img src="/assets/media/images/ray-tracer/chkpt3_img2.png">
        </a>
        <figcaption>
          <h4>With supersampling x4</h4>
        </figcaption>
      </figure>

      <figure>
        <a href="/assets/media/images/ray-tracer/chkpt3_img3.png"
           class="phong_group" data-modal-group=".phong_group"
           data-modal-title="With supersampling x9">
          <img src="/assets/media/images/ray-tracer/chkpt3_img3.png">
        </a>
        <figcaption>
          <h4>With supersampling x9</h4>
        </figcaption>
      </figure>

      <figure>
        <a href="/assets/media/images/ray-tracer/chkpt3_img4.png"
           class="phong_group" data-modal-group=".phong_group"
           data-modal-title="With supersampling x16">
          <img src="/assets/media/images/ray-tracer/chkpt3_img4.png">
        </a>
        <figcaption>
          <h4>With supersampling x16</h4>
        </figcaption>
      </figure>
      <button></button>
      <button class="forward"></button>
    </div>
  </section>

  <section>
    <div id="ProceduralCarousel" class="carousel" data-carousel-mode="slide">
      <h3>Procedural Textures</h3>
      <ol>
        <li></li>
      </ol>

      <figure class="carousel-active">
        <a href="/assets/media/images/ray-tracer/chkpt4_img1.png"
           class="frame_group" data-modal-group=".frame_group"
           data-modal-title="Procedural checkerboard texture">
          <img src="/assets/media/images/ray-tracer/chkpt4_img1.png">
        </a>
        <figcaption>
          <h4>Procedural checkerboard texture</h4>
        </figcaption>
      </figure>
    </div>
  </section>

  <section>
    <div id="ReflectionCarousel" class="carousel" data-carousel-mode="slide">
      <h3>Reflection</h3>
      <ol>
        <li></li>
      </ol>

      <figure class="carousel-active">
        <a href="/assets/media/images/ray-tracer/chkpt5_img1.png"
           class="frame_group" data-modal-group=".frame_group"
           data-modal-title="Reflection">
          <img src="/assets/media/images/ray-tracer/chkpt5_img1.png">
        </a>
        <figcaption>
          <h4>Reflection</h4>
        </figcaption>
      </figure>
    </div>
  </section>

  <section>
    <h3>Transmission</h3>
    <p>Not yet assigned!</p>
  </section>

  <section>
    <h3>Tone Reproduction</h3>
    <p>Not yet assigned!</p>
  </section>
</div>

Additionally, the project has semi-optional advanced checkpoints. These will be detailed below as they become implemented.
