#include <Rcpp.h>
using namespace Rcpp;

// This is a simple example of exporting a C++ function to R. You can
// source this function into an R session using the Rcpp::sourceCpp
// function (or via the Source button on the editor toolbar). Learn
// more about Rcpp at:
//
//   http://www.rcpp.org/
//   http://adv-r.had.co.nz/Rcpp.html
//   http://gallery.rcpp.org/
//

// [[Rcpp::export]]
std::string a_sptree_open(bool standalone, int id, double offx, double offy) {
  std::stringstream os;

  if( standalone ){
    os << "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>";
    os << "<p:spTree xmlns:a=\"http://schemas.openxmlformats.org/drawingml/2006/main\" ";
    os << "xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\" ";
    os << "xmlns:p=\"http://schemas.openxmlformats.org/presentationml/2006/main\" >";
  } else {
    os << "<p:spTree>";
  }

  os << "<p:nvGrpSpPr>";
    os << "<p:cNvPr id=\"" << id << "\" name=\"table" << id << "\"/>";
    os << "<p:cNvGrpSpPr/>";
    os << "<p:nvPr/>";
  os << "</p:nvGrpSpPr>";
  os << "<p:grpSpPr>";
    os << "<a:xfrm>";
      os << "<a:off x=\"0\" y=\"0\"/>";
      os << "<a:ext cx=\"0\" cy=\"0\"/>";
      os << "<a:chOff x=\"0\" y=\"0\"/>";
      os << "<a:chExt cx=\"0\" cy=\"0\"/>";
    os << "</a:xfrm>";
  os << "</p:grpSpPr>";
  os << "<p:graphicFrame>";

    os << "<p:nvGraphicFramePr>";
      os << "<p:cNvPr id=\"" << id << "\" name=\"nvGraphicFrame " << id << "\"/>";
      os << "<p:cNvGraphicFramePr><a:graphicFrameLocks noGrp=\"true\"/></p:cNvGraphicFramePr>";
      os << "<p:nvPr/>";
    os << "</p:nvGraphicFramePr>";

      os << "<p:xfrm rot=\"0\">";
        os << "<a:off x=\"" << (int)(offx * 12700) << "\" y=\"" << (int)(offy * 12700) << "\"/>";
      os << "</p:xfrm>";
      os << "<a:graphic>";
        os << "<a:graphicData uri=\"http://schemas.openxmlformats.org/drawingml/2006/table\">";
    return os.str();
}

// [[Rcpp::export]]
std::string a_graphic_frame_open(int id, double offx, double offy) {
  std::stringstream os;

  os << "<p:graphicFrame>";

  os << "<p:nvGraphicFramePr>";
    os << "<p:cNvPr id=\"" << id << "\" name=\"nvGraphicFrame " << id << "\"/>";
    os << "<p:cNvGraphicFramePr><a:graphicFrameLocks noGrp=\"true\"/></p:cNvGraphicFramePr>";
    os << "<p:nvPr/>";
  os << "</p:nvGraphicFramePr>";

  os << "<p:xfrm rot=\"0\">";
    os << "<a:off x=\"" << (int)(offx * 12700) << "\" y=\"" << (int)(offy * 12700) << "\"/>";
  os << "</p:xfrm>";
  os << "<a:graphic>";
    os << "<a:graphicData uri=\"http://schemas.openxmlformats.org/drawingml/2006/table\">";
  return os.str();
}

// [[Rcpp::export]]
std::string a_sptree_close() {
  std::stringstream os;
        os << "</a:graphicData>";
      os << "</a:graphic>";
    os << "</p:graphicFrame>";
  os << "</p:spTree>";

  return os.str();
}

// [[Rcpp::export]]
std::string a_graphic_frame_close() {
  std::stringstream os;
      os << "</a:graphicData>";
    os << "</a:graphic>";
  os << "</p:graphicFrame>";

  return os.str();
}

