#ifndef ThorVGCanvasImpl_h
#define ThorVGCanvasImpl_h

#include "Canvas.h"

#include <thorvg/thorvg.h>

namespace lottieRendering {

class ThorVGCanvasImpl: public Canvas {
public:
    ThorVGCanvasImpl(int width, int height);
    virtual ~ThorVGCanvasImpl();
    
    virtual int width() const override;
    virtual int height() const override;
    
    virtual std::shared_ptr<Canvas> makeLayer(int width, int height) override;
    
    virtual void saveState() override;
    virtual void restoreState() override;
    
    virtual void fillPath(std::shared_ptr<lottie::CGPath> const &path, lottie::FillRule fillRule, lottie::Color const &color) override;
    virtual void linearGradientFillPath(std::shared_ptr<lottie::CGPath> const &path, lottie::FillRule fillRule, lottieRendering::Gradient const &gradient, lottie::Vector2D const &start, lottie::Vector2D const &end) override;
    virtual void radialGradientFillPath(std::shared_ptr<lottie::CGPath> const &path, lottie::FillRule fillRule, lottieRendering::Gradient const &gradient, lottie::Vector2D const &startCenter, float startRadius, lottie::Vector2D const &endCenter, float endRadius) override;
    virtual void strokePath(std::shared_ptr<lottie::CGPath> const &path, float lineWidth, lottie::LineJoin lineJoin, lottie::LineCap lineCap, float dashPhase, std::vector<float> const &dashPattern, lottie::Color const &color) override;
    virtual void linearGradientStrokePath(std::shared_ptr<lottie::CGPath> const &path, float lineWidth, lottie::LineJoin lineJoin, lottie::LineCap lineCap, float dashPhase, std::vector<float> const &dashPattern, Gradient const &gradient, lottie::Vector2D const &start, lottie::Vector2D const &end) override;
    virtual void radialGradientStrokePath(std::shared_ptr<lottie::CGPath> const &path, float lineWidth, lottie::LineJoin lineJoin, lottie::LineCap lineCap, float dashPhase, std::vector<float> const &dashPattern, Gradient const &gradient, lottie::Vector2D const &startCenter, float startRadius, lottie::Vector2D const &endCenter, float endRadius) override;
    virtual void fill(lottie::CGRect const &rect, lottie::Color const &fillColor) override;
    
    virtual void setBlendMode(BlendMode blendMode) override;
    
    virtual void setAlpha(float alpha) override;
    
    virtual void concatenate(lottie::CATransform3D const &transform) override;
    virtual lottie::CATransform3D currentTransform() override;
    
    virtual void draw(std::shared_ptr<Canvas> const &other, lottie::CGRect const &rect) override;
    
    uint32_t *backingData() {
        return _backingData;
    }
    
    int bytesPerRow() const {
        return _bytesPerRow;
    }
    
    void flush();
    
private:
    int _width = 0;
    int _height = 0;
    std::unique_ptr<tvg::SwCanvas> _canvas;

    float _alpha = 1.0;
    lottie::CATransform3D _transform;
    std::vector<lottie::CATransform3D> _stateStack;
    int _bytesPerRow = 0;
    uint32_t *_backingData = nullptr;
    int _statsNumStrokes = 0;
};

}

#endif
